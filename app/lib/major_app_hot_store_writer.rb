class MajorAppHotStoreWriter

  # These methods write to the hotstore all the apps that are found in the
  # top 200 free and grossing charts.

  def write_ios_major_charts
    #TODO: SET alert if amount of rankings are too low!

    # Array of hashes
    apps = apps_from_rankings_chart_in(IosApp::PLATFORM_NAME)
    find_and_send_to_hotstore(apps)
  end

  def write_android_major_charts
    #TODO: SET alert if amount of rankings are too low!
    apps  = apps_from_rankings_chart_in(AndroidApp::PLATFORM_NAME)
    find_and_send_to_hotstore(apps)
  end


  # These methods write to the hotstore the relevant apps that have been
  # marked as major or their publisher has been marked as major

  def write_major_app_tag
    major_apps = (
      Tag.find_by(name: "Major App")
        .android_apps
        .relevant_since(HotStore::TIME_OF_RELEVANCE) +
      Tag.find_by(name: "Major App")
        .ios_apps
        .relevant_since(HotStore::TIME_OF_RELEVANCE)
    )

    send_to_hotstore(major_apps)
    true
  end

  def write_major_publisher_tag
    major_publishers = (
      Tag.find_by(name: "Major Publisher")
        .android_developers +
      Tag.find_by(name: "Major Publisher")
        .ios_developers
    )

    major_apps = major_publishers.reduce([]) do |memo, publisher|
      memo.concat(publisher.apps.relevant_since(AppHotStore::TIME_OF_RELEVANCE))
    end

    send_to_hotstore(major_apps)
    true
  end


  # This will be refactored in the company id project
  # to not rely on the DomainDatum table
  def write_fortune_1000
    # nils prevent returning which can cause OOM

    #TODO: refactor to send only relevant appStores
    # and use batches to query the db
    domain_linker = DomainLinker.new
    DomainDatum.where.not(:fortune_1000_rank => nil).uniq.map do |dd|
      domain_linker.domain_to_publisher(dd.domain).map do |publisher|
        send_to_hotstore(publisher.apps.relevant_since(AppHotStore::TIME_OF_RELEVANCE)) #TODO: Select relevan apps
        nil
      end
      nil
    end
  end

  private

  def _write_app(app)
    hs = AppHotStore.new
    hs.write_major_app(app.id, app.app_identifier, app.platform, major_app: true)
  end

  def apps_from_rankings_chart_in(platform)

    category = platform == IosApp::PLATFORM_NAME ? '36' : 'OVERALL'

    (
      RankingsAccessor.new.get_chart(platform: platform, country: 'US', category: category, rank_type: 'free', size: 200)['apps'] +
      RankingsAccessor.new.get_chart(platform: platform, country: 'US', category: category, rank_type: 'grossing', size: 200)['apps']
    )
  end

  def find_and_send_to_hotstore(apps_hashes)
    apps = find_apps(apps_hashes)
    send_to_hotstore(apps)
  end


  # Set the value in the hotstore w/o repeating values based on app_identifier
  def send_to_hotstore(apps)
    sent_apps = Set.new

    apps.each do |app|
      identifier = app.app_identifier
      next if sent_apps.include?(identifier)
      _write_app(app)
      sent_apps.add(identifier)
    end

    true
  end


  # Receive arrays of hashes like this:
  # [
  #   {"created_at"=>"2020-12-01 01:29:18 -0500", "platform"=>"ios", "country"=>"US", "category"=>"36", "ranking_type"=>"grossing", "app_identifier"=>"com.someapp.doh", "rank"=>1},
  #   {"created_at"=>"2020-12-01 01:29:18 -0500", "platform"=>"ios", "country"=>"US", "category"=>"36", "ranking_type"=>"grossing", "app_identifier"=>"br.someotherapp.blah", "rank"=>2}
  # ]
  # Returns an array of app objects. It can handle a mix of both AndroidApp and IosApp
  def find_apps(app_hashes_array)
    queryable_apps = app_hashes_array.inject({}) do |memo, app|

      app        = app.with_indifferent_access
      platform   = app['platform']
      identifier = app['app_identifier']

      next unless platform.present? && identifier.present?

      clazz      = "#{platform.capitalize}App".constantize

      if memo[clazz].present?
        memo[clazz] << identifier
      else
        memo[clazz] = [identifier]
      end

      memo
    end

    # query all of same class at once to reduce DB hits
    queryable_apps.inject([]) do |memo, (clazz, identifiers)|
      memo.concat clazz.where(app_identifier: identifiers).to_a
    end
  end


end
