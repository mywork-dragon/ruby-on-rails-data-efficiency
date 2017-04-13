class ClearbitWorker

  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :clearbit

  IOS_DEVELOPER_IDS = {
    'google.com' => [6864],
    'goo.gl' => [6864],
    'youtube.com' => [6864],
    'youtu.be' => [6864],
    'yahoo.com'  => [73828],
    'facebook.com' => [37304],
    'fb.com'  => [37304],
    'facebook.co' => [37304],
    'instagram.com' => [98351],
    'twitter.com' => [268130],
    'zendesk.com' => [74232],
    'helpshift.com' => [],
    'wix.com' => [73203],
    'uservoice.com' => [249774],
    'weebly.com' => [99862],
    'wordpress.com' => [58683],
    'wordpress.org' => [58683],
    'amazon.com' => [8574],
    'desk.com' => [33041],
    'bit.ly' => [1557358],
    'blogspot.com' => [],
    'pinterest.com' => [262604],
    'tumblr.com' => [265243],
    'webs.com' => [312507],
    'sina.com.cn' => [12712],
    'sina.com' => [12712],
    'weibo.com' => [12712],
    'naver.com' => [99423],
    'appspot.com' => [],
    'apple.com' => [47346],
    'itunes.com' => [47346],
    'freshdesk.com' => [39580],
    'qq.com' => [84000, 91496, 60230],
    'aol.com' => [36017],
    'aim.com' => [36017],
    'cocos2d-x.org' => [],
    'github.com' => [],
    'strikingly.com' => [280303],
    'about.me' => [45453],
    'yolasite.com' => []
  }

  ANDROID_DEVELOPER_IDS = {
    'google.com' => [26],
    'goo.gl' => [26],
    'youtube.com' => [26],
    'youtu.be' => [26],
    'yahoo.com'  => [37],
    'facebook.com' => [55],
    'fb.com'  => [55],
    'facebook.co'  => [55],
    'instagram.com' => [101],
    'twitter.com' => [125],
    'zendesk.com' => [83735],
    'helpshift.com' => [],
    'wix.com' => [382764],
    'uservoice.com' => [190377],
    'weebly.com' => [47842],
    'wordpress.com' => [15621],
    'wordpress.org' => [15621],
    'amazon.com' => [8],
    'desk.com' => [91892],
    'bit.ly' => [649390],
    'blogspot.com' => [],
    'pinterest.com' => [547],
    'tumblr.com' => [331],
    'webs.com' => [658726],
    'sina.com.cn' => [71943],
    'sina.com' => [71943],
    'weibo.com' => [71943],
    'naver.com' => [108],
    'appspot.com' => [],
    'apple.com' => [426619],
    'itunes.com' => [426619],
    'freshdesk.com' => [29398],
    'qq.com' => [22669, 498, 23991],
    'aol.com' => [16551],
    'aim.com' => [16551],
    'cocos2d-x.org' => [],
    'github.com' => [],
    'strikingly.com' => [],
    'about.me' => [343529],
    'yolasite.com' => []
  }

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end

  def queue_ios_apps(user_base)
    IosApp.where(id: IosAppCurrentSnapshot.where(user_base: user_base).pluck(:ios_app_id)).each do |app|
      next if app.headquarters.any?
      ClearbitWorker.perform_async(:enrich_app, app.id, 'ios')
    end
  end

  def queue_android_apps(user_base)
    AndroidApp.where(user_base: user_base).each do |app|
      next if app.headquarters.any?
      ClearbitWorker.perform_async(:enrich_app, app.id, 'android')
    end
  end

  def queue_n_apps_for_enrichment(n)
    ios_apps = get_n_non_enriched_apps(n / 2, IosApp.count) {|offset, limit| IosApp.where.not(:user_base => nil).order(:user_base).offset(offset).limit(limit)}
    android_apps = get_n_non_enriched_apps(n / 2, AndroidApp.count) {|offset, limit| AndroidApp.where.not(:user_base => nil).order(:user_base).offset(offset).limit(limit)}
    ios_apps.each {|app| ClearbitWorker.perform_async(:enrich_app, app.id, 'ios')}
    android_apps.each {|app| ClearbitWorker.perform_async(:enrich_app, app.id, 'android')}
    puts "Queued #{ios_apps.count} iOS Apps for enrichment."
    puts "Queued #{android_apps.count} Android Apps for enrichment."
    {'ios_apps' => ios_apps, 'android_apps' => android_apps}
  end

  def get_n_non_enriched_apps(n, limit)
    # Expects a block which accepts and offset and limit parameter
    # and returns apps.
    apps = []
    i = 0
    increment = n * 2
    while apps.count < n and i < limit
      yield(i, increment).each do |app|
        next if app.headquarters.any?
        apps.append(app)
        if apps.count >= n
          break
        end
      end
      i += increment
    end
    apps
  end

  def populate_domains
    DomainDatum.where(clearbit_id: nil).each do |datum|
      puts "Populating #{datum.domain}"
      begin
        company_data = Clearbit::Company.find(domain: datum.domain, stream: true)
        puts company_data
        datum.populate(company_data)
      rescue
      end
    end
  end 

  def flag_ios_websites
    IOS_DEVELOPER_IDS.each do |domain, ids|
      developer_website_ids = Website.where("url LIKE '%#{domain}%'").joins(:ios_developers_websites => :ios_developer).
      where.not('ios_developers.id' => ids).pluck('ios_developers_websites.id')
      IosDevelopersWebsite.where(id: developer_website_ids).update_all(is_valid: false)
    end
  end

  def flag_android_websites
    ANDROID_DEVELOPER_IDS.each do |domain, ids|
      developer_website_ids = Website.where("url LIKE '%#{domain}%'").joins(:android_developers_websites => :android_developer).
      where.not('android_developers.id' => ids).pluck('android_developers_websites.id')
      AndroidDevelopersWebsite.where(id: developer_website_ids).update_all(is_valid: false)
    end 
  end

  def populate_domain_datum 
    ClearbitContact.where(domain_datum_id: nil).each do |contact|
      puts "Doing contact #{contact.id}"
      next unless contact.website && contact.website.domain
      domain_datum = DomainDatum.find_or_create_by(domain: contact.website.domain)
      domain_datum.clearbit_contacts << contact unless domain_datum.clearbit_contacts.include?(contact)
    end
  end

  def enrich_app(app_id, platform)
    puts "Processing app #{app_id}"
    if platform == 'ios'
      app = IosApp.find(app_id)
      developer = app.ios_developer
      urls = [app.seller_url, app.support_url]
    else
      app = AndroidApp.find(app_id)
      developer = app.android_developer
      urls = [app.seller_url]
    end
    
    if developer.blank?
      puts "Could not find app developer #{app.id}"
      if platform == 'ios'
        AppStoreDevelopersWorker.new.perform(:create_by_ios_app_id, app_id)
      else
        GooglePlayDevelopersWorker.new.perform(:create_by_android_app_id, app_id)
      end
    end

    return unless developer

    urls.compact.each do |url|
      website = Website.find_or_create_by(url: url)
      developer.websites << website unless developer.websites.include?(website)
    end
    
    developer.websites.each do |website|
      domain = UrlHelper.url_with_domain_only(website.url)
      
      begin
        company_data = Clearbit::Company.find(domain: domain, stream: true)
        domain_datum = DomainDatum.find_or_create_by(domain: domain)
      ensure
        domain_datum ||= DomainDatum.find_or_create_by(domain: domain)
        domain_datum.populate(company_data) if company_data
        domain_datum.websites << website unless domain_datum.websites.include?(website)
      end
    end
  end
end
