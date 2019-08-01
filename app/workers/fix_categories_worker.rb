class FixCategoriesWorker
  # This class fix the categories for all android and ios apps

  ######################## INSTRUCTIONS ################################

  # This script is executed as follow:
  # FixCategoriesWorker.new.queue_apps

  include Sidekiq::Worker
    
  sidekiq_options queue: :category_fix
  STREAM_NAME = 'category_fix'


  def kinds
    @kinds ||= IosAppCategoriesCurrentSnapshot.kinds
  end

  def apps_hot_store
    @apps_hot_store ||= AppHotStore.new
  end
  
  
  def perform(app, platform='ios')
    platform == 'ios' ? ios_perform(app) : android_perform(app)
  end

  def queue_ios_apps
    IosApp.find_each.lazy do |iapp|
      FixCategoriesWorker.new.perform_async("ios", iapp)
    end
  end

  def queue_android_apps
    AndroidApp.find_each.lazy do |aapp|
      FixCategoriesWorker.new.perform_async("android", aapp)
    end
  end
  
  def queue_apps
    queue_ios_apps
    queue_android_apps
  end

  def android_perform(app)
    print "processing #{app.id} "
    attributes = GooglePlayService.attributes(app.app_identifier)
    category = AndroidAppCategory.find_or_create_by(category_id: attributes[:category_id], name: attributes[:category_name])

    AndroidApp.transaction do
      to_remove = []
      to_remove = app.newest_android_app_snapshot.android_app_categories.map do |app_category|
        next if app_category.id == category.id
        app_category
      end.compact
      app.newest_android_app_snapshot.android_app_categories.destroy(to_remove) unless to_remove.blank?

      if app.newest_android_app_snapshot.android_app_categories.count == 0
        app.newest_android_app_snapshot.android_app_categories << category
      end

      # update the hotstore
      hs_categories = app.newest_android_app_snapshot.android_app_categories.map{|cateogry| {"id"=>category.id, "name"=> category.name}}
      apps_hot_store.write_attribute(app.id, app.app_identifier, 'android', "categories", hs_categories)
    end
    puts " done "
  rescue => error
    logger.error("#{app.id} = #{error.message}")
    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: "android, #{app.id}, #{e.message}")
  end


  def ios_perform(app)
    print "processing #{app.id} "
    # get the app scraped attributes
    primary_cat, secondary_cat = get_ios_real_categories(app)

    # search for the latest current snapshot with the correct categories
    correct_last_snapshot = app.ios_app_current_snapshots.where(latest: true)
    .joins(:ios_app_categories_current_snapshots)
    .where(
      'ios_app_categories_current_snapshots.kind': kinds.values, 
      'ios_app_categories_current_snapshots.ios_app_category_id': [primary_cat, secondary_cat].map{|cat| cat.id if cat}.compact
    ).last

    IosApp.transaction do   
      if correct_last_snapshot
        # Invalidate the corrupted ios app categories snapshots
        invalidate_corrupted_ios_app_categories(correct_last_snapshot.id, primary_cat, secondary_cat)
        # Invalidate corrupted snapshots and keep the correct one
        invalidate_corrupted_snapshots(app, correct_last_snapshot.id)
      else
        # If there is no snapshot with the correct categories then create a new one
        current_snapshot = create_new_ios_current_snapshot(app)
        create_ios_category_current_snapshot(current_snapshot.id, :primary, primary_cat)
        create_ios_category_current_snapshot(current_snapshot.id, :secondary, secondary_cat) unless secondary_cat.blank?
      end

      # update the hotstore
      hs_categories = [{"id"=>primary_cat.id, "name"=> primary_cat.name, "type"=>"primary"}]
      hs_categories << {"id"=>secondary_cat.id, "name"=> secondary_cat.name, "type"=>"secondary"} unless secondary_cat.blank?
      apps_hot_store.write_attribute(app.id, app.app_identifier, 'ios', "categories", hs_categories)
    end
    puts " done "
  rescue => error
    logger.error("#{app.id} = #{error.message}")
    MightyAws::Firehose.new.send(stream_name: STREAM_NAME, data: "ios, #{app.id}, #{e.message}")
  end


  def get_ios_real_categories(app)
    attributes = AppStoreService.attributes(app.app_identifier)
    categories = attributes[:categories]
    primary_cat = IosAppCategory.find_or_create_by(name: categories[:primary])
    secondary_cat = IosAppCategory.find_or_create_by(name: categories[:secondary].first) unless categories[:secondary].blank?
    return primary_cat, secondary_cat
  end


  def invalidate_corrupted_ios_app_categories(correct_last_snapshot_id, primary_cat, secondary_cat)
    IosAppCategoriesCurrentSnapshot.where(
      ios_app_current_snapshot_id: correct_last_snapshot_id, 
      kind: kinds[:primary]
    ).where.not(ios_app_category_id: primary_cat.id).destroy_all
    IosAppCategoriesCurrentSnapshot.where(
      ios_app_current_snapshot_id: correct_last_snapshot_id, 
      kind: kinds[:secondary]
    ).where.not(ios_app_category_id: secondary_cat.id).destroy_all unless secondary_cat.blank?
  rescue => error
    logger.error("ips app category snapshot invalidation failed: #{error.message}")
  end


  def invalidate_corrupted_snapshots(ios_app, keep_this_snapshot_id=nil)
    corrupted_snaps = ios_app.ios_app_current_snapshots.where(latest: true).pluck(:id)
    to_invalidate = keep_this_snapshot_id.blank? ? corrupted_snaps : corrupted_snaps - [keep_this_snapshot_id]
    ios_app.ios_app_current_snapshots.where(id: to_invalidate).update_all(latest: nil) unless to_invalidate.blank?
  rescue => error
    logger.error("ips app current snapshot invalidation failed: #{error.message}")
  end
  

  def create_new_ios_current_snapshot(ios_app)
    # create a duplicate of the last snapshot with all the parameters and relationships
    current_snapshot = ios_app.ios_app_current_snapshots.where(latest: true).last.dup
    current_snapshot = ios_app.ios_app_current_snapshots.last if current_snapshot.blank?
    invalidate_corrupted_snapshots(ios_app)
    current_snapshot.save!
    current_snapshot
  rescue => error
    logger.error("ios current snapshot creation failed: #{error.message}")
  end


  def create_ios_category_current_snapshot(current_snapshot_id, kind, category)
    primary_cat_current_snapshot = IosAppCategoriesCurrentSnapshot.new
    primary_cat_current_snapshot.ios_app_current_snapshot_id = current_snapshot_id
    primary_cat_current_snapshot.kind = kind
    primary_cat_current_snapshot.ios_app_category = category
    primary_cat_current_snapshot.save!
  rescue => error
    logger.error("ios category current snapshot creation failed: #{error.message}")
  end
end