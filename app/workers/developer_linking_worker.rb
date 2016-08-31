class DeveloperLinkingWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sdk, retry: false

  class BadFormat; end
  class DoNotLink; end

  def perform(method, *args)
    send(method.to_sym, *args)
  end

  def link_by_ios_developer_name(ios_developer_id)
    ios_developer = IosDeveloper.find(ios_developer_id)
    name = ios_developer.name.chomp
    return puts 'empty name' unless name

    regex = name_regex(name)
    potential_matches = AndroidDeveloper.where('name REGEXP ?', regex)

    rows = potential_matches.map do |android_developer|
      DeveloperLinkOption.new(
        ios_developer_id: ios_developer.id,
        android_developer_id: android_developer.id,
        method: :name_match
      )
    end

    DeveloperLinkOption.import rows
  end

  def name_regex(ios_developer_name)
    regex = ios_developer_name.split('').map do |char|
      if /[^\p{Alnum}]/.match(char)
        '[^a-zA-Z0-9]?'
      else
        char
      end
    end.join('')
  end

  def link_by_ios_developer_websites(ios_developer_id)
    ios_developer = IosDeveloper.find(ios_developer_id)

    match_strings = ios_developer.websites.pluck(:match_string).compact.uniq
    match_strings.select! { |match_string| valid_match_string?(match_string) }
    return if match_strings.empty?

    matching_android_developers = AndroidDeveloper.joins(:websites).where('websites.match_string in (?)', match_strings)

    rows = matching_android_developers.map do |android_developer|
      DeveloperLinkOption.new(
        ios_developer_id: ios_developer.id,
        android_developer_id: android_developer.id,
        method: :website_match
      )
    end

    DeveloperLinkOption.import rows
  end

  def fill_clusters(developer_link_option_id)
    developer_link_option = DeveloperLinkOption.find(developer_link_option_id)
    ios_list = [developer_link_option.ios_developer_id]
    android_list = [developer_link_option.android_developer_id]

    return puts 'Already exists' if app_developer_exists?(ios_list, android_list)

    previous_length = 0

    while previous_length < ios_list.count + android_list.count
      previous_length = ios_list.count + android_list.count
      puts "Current cluster size: #{previous_length}"
      links = DeveloperLinkOption
        .select(:ios_developer_id, :android_developer_id)
        .where('ios_developer_id in (?) or android_developer_id in (?)', ios_list, android_list)
      ios_list = links.map(&:ios_developer_id).compact.uniq
      android_list = links.map(&:android_developer_id).compact.uniq
    end

    return puts 'Already exists after querying' if app_developer_exists?(ios_list, android_list)
    save_cluster(ios_list, android_list)
  end

  def save_cluster(ios_developer_ids, android_developer_ids)
    # need to find the name
    name = cluster_name(ios_developer_ids, android_developer_ids)
    return puts 'Will not link' if name == DoNotLink

    app_developer = AppDeveloper.create!(name: name)
    joins_rows = ios_developer_ids.map do |ios_developer_id|
      AppDevelopersDeveloper.new(
        app_developer_id: app_developer.id,
        developer_id: ios_developer_id,
        developer_type: 'IosDeveloper'
      )
    end
    joins_rows += android_developer_ids.map do |android_developer_id|
      AppDevelopersDeveloper.new(
        app_developer_id: app_developer.id,
        developer_id: android_developer_id,
        developer_type: 'AndroidDeveloper'
      )
    end

    AppDevelopersDeveloper.import joins_rows
  end

  def cluster_name(ios_developer_ids, android_developer_ids)
    # if theres a name match, use that name
    name_link = DeveloperLinkOption
      .where('ios_developer_id in (?) or android_developer_id in (?)', ios_developer_ids, android_developer_ids)
      .where(method: DeveloperLinkOption.methods[:name_match]).limit(1).take

    IosDeveloper.find(name_link.ios_developer_id).name if name_link

    # if not, use the developer with the most apps
    ios_developer = IosDeveloper.select(:id, :name).select('count(*)')
      .joins(:ios_apps).where(id: ios_developer_ids)
      .group(:id).order('count(*) DESC').first

    return ios_developer.name if ios_developer

    android_developer = AndroidDeveloper.select(:id, :name).select('count(*)')
      .joins(:android_apps).where(id: android_developer_ids)
      .group(:id).order('count(*) DESC').first

    return android_developer.name if android_developer

    # if there aren't name links and they do not have apps, probably not worth linking
    DoNotLink
  end

  def app_developer_exists?(ios_developer_ids, android_developer_ids)
    return true if AppDevelopersDeveloper.find_by(developer_type: 'IosDeveloper', developer_id: ios_developer_ids)
    return true if AppDevelopersDeveloper.find_by(developer_type: 'AndroidDeveloper', developer_id: android_developer_ids)
    false
  end


  def queue_ios_developers(function_name)
    batch_size = 1000
    IosDeveloper.select(:id)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|

      li "Developer #{index * batch_size}"

      args = the_batch.map do |ios_developer|
        [function_name.to_sym, ios_developer.id]
      end

      SidekiqBatchQueueWorker.perform_async(
        DeveloperLinkingWorker.to_s,
        args,
        bid
      )
    end
  end

  def queue_websites
    batch_size = 1000
    Website.select(:id)
      .where(match_string: nil)
      .find_in_batches(batch_size: batch_size)
      .with_index do |the_batch, index|
      
      li "Website #{index * batch_size}"

      args = the_batch.map do |website|
        [:fill_match_string, website.id]
      end

      SidekiqBatchQueueWorker.perform_async(
        DeveloperLinkingWorker.to_s,
        args,
        bid
      )
    end
  end

  def queue_link_options
    DeveloperLinkOption.select(:id, :ios_developer_id)
      .group(:ios_developer_id)
      .find_in_batches(batch_size: 1000) do |the_batch|

      args = the_batch.map do |developer_link_option|
        [:fill_clusters, developer_link_option.id]
      end

      SidekiqBatchQueueWorker.perform_async(
        DeveloperLinkingWorker.to_s,
        args,
        bid
      )
    end
  end

  def fill_match_string(website_id)
    website = Website.find(website_id)

    match_string = website_comparison_format(website.url)
    value = match_string == BadFormat ? nil : match_string

    website.match_string = value

    website.save!(validation: false)
  end

  def website_comparison_format(url)
    regex = %r{(?:https?://)?(?:www\.)?([^\s\?]+)}
    match = regex.match(url)
    return BadFormat unless match
    url_format = match[1]
    DbSanitizer.truncate_string(url_format)
  end

  def valid_match_string?(match_string)

    # ignore certain match strings
    ignore_regexes = [
      %r{youtube\.com/watch},
      %r{facebook\.com/profile\.php},
      %r{market\.android\.com/details},
      %r{linkedin\.com/profile/view},
      %r{^facebook\.com/\Z},
      %r{play\.google\.com},
      %r{youtube\.com/playlist},
      %r{itunes\.apple\.com},
      %r{facebook\.com/home\.php}
    ]

    return false if ignore_regexes.find { |regex| regex.match(match_string) }

    true
  end

  def check_matching(apps)
    File.open('output.txt', 'w') do |f|
      apps.select(&:ios_developer_id).each do |ios_app|
        f.write '' + "\n"
        f.write '-------------------' + "\n"
        f.write "App: #{ios_app.name}" + "\n"
        ios_developer = IosDeveloper.find(ios_app.ios_developer_id)

        unless app_developer = ios_developer.app_developer
          f.write 'Not linked' + "\n"
          next
        end

        f.write "App Developer: #{app_developer.name}" + "\n"
        f.write "Android developers: " + app_developer.android_developers.pluck(:name).join(', ') + "\n"
        f.write "iOS developers: " + app_developer.ios_developers.pluck(:name).join(', ') + "\n"
      end
    end
  end
end
