class DeveloperLinkingWorker
  include Sidekiq::Worker

  sidekiq_options queue: :sdk, retry: false

  class BadFormat; end

  def perform(method, *args)
    send(method.to_sym, *args)
  end

  def link_by_ios_developer_name(ios_developer_id)
    ios_developer = IosDeveloper.find(ios_developer_id)
    potential_matches = AndroidDeveloper.where(name: ios_developer.name)

    rows = potential_matches.map do |android_developer|
      DeveloperLinkOption.new(
        ios_developer_id: ios_developer.id,
        android_developer_id: android_developer.id,
        method: :name_match
      )
    end

    DeveloperLinkOption.import rows
  end

  def link_by_ios_developer_websites(ios_developer_id)
    ios_developer = IosDeveloper.find(ios_developer_id)
    match_strings = ios_developer.websites.pluck(:match_string).compact.uniq
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
end
