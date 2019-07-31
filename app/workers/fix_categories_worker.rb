class FixCategoriesWorker
  include Sidekiq::Worker
    
  sidekiq_options queue: :category_fix


  def apps_hot_store
    @apps_hot_store ||= AppHotStore.new
  end
  
  
  def perform(app_ids, platform='ios')
    platform == 'ios' ? ios_perform(app_ids) : android_perform(app_ids)
  end

  def queue_ios_apps
    IosApp.pluck(:id).each_slice(1000) do |ids|
      FixCategoriesWorker.perform_async("ios", ids)
    end
  end

  def queue_android_apps
    AndroidApp.pluck(:id).each_slice(1000) do |ids|
      FixCategoriesWorker.perform_async("android", ids)
    end
  end
  
  def queue_apps
    queue_ios_apps
    queue_android_apps
  end

  def android_perform(app_ids)
    app_ids.each do |app_id|
      app = AndroidApp.find(app_id)
      attributes = GooglePlayService.attributes(app.app_identifier)
      category = AndroidAppCategory.find_or_create_by(category_id: attributes[:category_id])
      if category.name.nil? && attributes[:category_name]
        category.update!(:name => attributes[:category_name])
      end

      AndroidApp.transaction do
        begin
          to_remove = []
          app.newest_android_app_snapshot.android_app_categories do |app_category|
            to_remove << app_category if app_category.id != category.id
          end
          app.newest_android_app_snapshot.android_app_categories.delete(to_remove) if to_remove

          if app.newest_android_app_snapshot.android_app_categories.count == 0
            app.newest_android_app_snapshot.android_app_categories << category
          end

          # update the hotstore
          hs_categories = app.newest_android_app_snapshot.android_app_categories.map{|cateogry| {"id"=>category.id, "name"=> category.name}}
          apps_hot_store.write_attribute(app.id, app.app_identifier, 'android', "categories", hs_categories)
        rescue => error
          logger.error("#{app.id} = #{error.message}")
        end
      end
    end
  end

  def ios_perform(app_ids)
    app_ids.each do |app_id|
      app = IosApp.find(app_id)
  
      # get the scraped attributes
      attributes = AppStoreService.attributes(app.app_identifier)
      categories = attributes[:categories]
      primary_cat = IosAppCategory.find_or_create_by(name: categories[:primary])
      secondary_cat = IosAppCategory.find_or_create_by(name: categories[:secondary].first)
  
      # invalidate all the previous current_snapshots and activate just one
      last_snapshots = app.ios_app_current_snapshots.where(latest: true)
      # find the snapshots categories
      real_last_snapshot_id = nil

      IosApp.transaction do
        begin
          last_snapshots.each do |last_snapshot|
            primary_cat_snapshot = IosAppCategoriesCurrentSnapshot.where(ios_app_current_snapshot_id: last_snapshot.id, kind: 0, ios_app_category_id: primary_cat.id).first
            secondary_cat_snapshot = IosAppCategoriesCurrentSnapshot.where(ios_app_current_snapshot_id: last_snapshot.id, kind: 1, ios_app_category_id: secondary_cat.id).first
            
            # keep the real category snapshot 
            if primary_cat_snapshot.ios_app_category_id == primary_cat.id
              if secondary_cat_snapshot && secondary_cat_snapshot.ios_app_category_id == secondary_cat.id
                real_last_snapshot_id = last_snapshot.id
              end
            end
            
            # remove the corrupted categories
            IosAppCategoriesCurrentSnapshot.where(ios_app_current_snapshot_id: last_snapshot.id, kind: 0).where.not(ios_app_category_id: primary_cat.id).delete_all
            IosAppCategoriesCurrentSnapshot.where(ios_app_current_snapshot_id: last_snapshot.id, kind: 1).where.not(ios_app_category_id: secondary_cat.id).delete_all
          end
        
          if real_last_snapshot_id
            # Invalidate corrupted snapshots and keep the correct one
            to_invalidate = app.ios_app_current_snapshots.where(latest: true).pluck(:id) - [real_last_snapshot_id]
            app.ios_app_current_snapshots.where(id: to_invalidate).update_all(latest: nil) unless to_invalidate.empty?
          else
            # create a new snapshot from a copy and set the correct categories
            current_snapshot = app.ios_app_current_snapshots.where(latest: true).last.dup
            to_invalidate = app.ios_app_current_snapshots.where(latest: true).pluck(:id)
            app.ios_app_current_snapshots.where(id: to_invalidate).update_all(latest: nil) unless to_invalidate.empty?
            current_snapshot.save!
            
            primary_cat_current_snapshot = IosAppCategoriesCurrentSnapshot.new 
            primary_cat_current_snapshot.ios_app_current_snapshot_id = current_snapshot.id
            primary_cat_current_snapshot.kind = :primary
            primary_cat_current_snapshot.ios_app_category = primary_cat
            primary_cat_current_snapshot.save!
            
            secondary_cat_current_snapshot = IosAppCategoriesCurrentSnapshot.new
            secondary_cat_current_snapshot.ios_app_current_snapshot_id = current_snapshot.id
            secondary_cat_current_snapshot.kind = :secondary
            secondary_cat_current_snapshot.ios_app_category = secondary_cat
            secondary_cat_current_snapshot.save!
          end

          # update the hotstore
          hs_categories = [
            {"id"=>primary_cat.id, "name"=> primary_cat.name, "type"=>"primary"},
            {"id"=>secondary_cat.id, "name"=> secondary_cat.name, "type"=>"secondary"}
          ]
          apps_hot_store.write_attribute(app.id, app.app_identifier, 'ios', "categories", hs_categories)
        rescue => error
          logger.error("#{app.id} = #{error.message}")
        end
      end
    end
  end
end