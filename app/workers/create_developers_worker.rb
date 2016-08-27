class CreateDevelopersWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => false, queue: :default

  def perform(method, *args)
    self.send(method.to_sym, *args)
  end
    
  def create_developers(app_id, platform)
    if platform == 'ios'
      app_class = IosApp
      developer_class = IosDeveloper
    else 
      app_class = AndroidApp
      developer_class = AndroidDeveloper
    end

    app = app_class.find(app_id)
    ss = platform == 'ios' ? app.newest_ios_app_snapshot : app.newest_android_app_snapshot
    return if ss.blank?
    # 1. Link all apps to developer by developer ID
    dev_id = platform == 'ios' ? ss.developer_app_store_identifier : ss.developer_google_play_identifier
    return if dev_id.blank?
    
    developer = developer_class.find_by_identifier(dev_id)
    developer = developer_class.create(identifier: dev_id, name: ss.seller) if developer.nil?

    if ss.seller_url
      seller_website = Website.find_or_create_by(url: ss.seller_url)
      developer.websites << seller_website unless developer.websites.include?(seller_website)
    end

    # 2. Link the app to the developer if it's not already
    if platform == 'ios' && app.ios_developer.blank?
      app.ios_developer = developer 
      app.save
    elsif app.respond_to?(:android_developer) && app.android_developer.blank?
      app.android_developer = developer
      app.save
    end
  end

  def dedupe_developers(dev_id, platform)
    if platform == 'ios'
      developer_class = IosDeveloper
    else
      developer_class = AndroidDeveloper
    end

    developers = developer_class.where(identifier: dev_id).to_a
    developer_to_keep = developers.shift
    developers.each do |dupe_developer|
      if platform == 'ios'
        dupe_developer.ios_apps.update_all(ios_developer_id: developer_to_keep.id)
        dupe_developer.ios_developers_websites.update_all(ios_developer_id: developer_to_keep.id)
      else
        dupe_developer.android_apps.update_all(android_developer_id: developer_to_keep.id)
        dupe_developer.android_developers_websites.update_all(android_developer_id: developer_to_keep.id)
      end
      dupe_developer.destroy
    end
  end
end
