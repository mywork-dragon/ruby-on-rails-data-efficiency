class AppsIndex < Chewy::Index

  settings analysis: {
    analyzer: {
      title: {
        tokenizer: 'standard',
        filter: ['lowercase', 'asciifolding']
      },
      lowercase: {
        tokenizer: 'keyword',
        filter: ['lowercase']
      }
    }
  }

  define_type IosApp.includes(:ios_developer, :newest_ios_app_snapshot) do

    crutch :current_snapshot do |collection|
      fields = ['ios_app_id', 'ios_app_current_snapshots.name', 'ratings_all_count', 'app_stores.country_code', 'app_stores.name', 'seller_name',
                'seller_url', 'user_base', 'price', 'first_released', 'mobile_priority', 'released']
      data = IosAppCurrentSnapshot.joins(:app_store).where(ios_app_id: collection.map(&:id)).order("ios_app_id, display_priority IS NULL, display_priority ASC").
                                   pluck(*fields)
      data.each.with_object({}) { |(id, name, ratings_all, country_code, country_name, seller_name, seller_url, user_base, price, first_released, mobile_priority, released), result|
        result[id] ||= {}
        result[id]['ios_app_id'] ||= id
        result[id]['ratings_all'] ||= ratings_all
        result[id]['name'] ||= name
        result[id]['price'] ||= price
        result[id]['seller_name'] ||= seller_name
        result[id]['seller_url'] ||= seller_url
        result[id]['mobile_priority'] ||= ::IosApp.mobile_priorities.key(mobile_priority)
        (result[id]['app_stores'] ||= []).push({name: country_name, country_code: country_code})
        (result[id]['user_bases'] ||= []).push({user_base: ::IosApp.user_bases.key(user_base), country_code: country_code, country: country_name})
        result[id]['first_released'] ||= first_released
        result[id]['last_updated'] ||= released
      }
    end

    crutch :old_ad_spend do |collection|
      data = IosFbAdAppearance.where(ios_app_id: collection.map(&:id)).pluck(:ios_app_id).uniq
      data.each.with_object({}) { |(id), result| result[id] = true }
    end

    crutch :ad_spend do |collection|
      data = IosFbAd.where(ios_app_id: collection.map(&:id)).
      group(:ios_app_id).select('ios_app_id', 'max(date_seen) as last_seen_ads', 'min(date_seen) as first_seen_ads')
      data.each.with_object({}) { |(app), result|
        id = app['ios_app_id']
        result[id] ||= {}
        result[id]['first_seen_ads'] = app['first_seen_ads']
        result[id]['last_seen_ads'] = app['last_seen_ads']
      }
    end

    crutch :scanned_date do |collection|
      data = IpaSnapshot.where(ios_app_id: collection.map(&:id)).where(scan_status: IpaSnapshot.scan_statuses[:scanned]).

      group(:ios_app_id).select('ios_app_id', 'max(good_as_of_date) as last_scanned', 'min(good_as_of_date) as first_scanned')
      data.each.with_object({}) { |(app), result|
        id = app['ios_app_id']
        result[id] ||= {}
        result[id]['first_scanned'] = app['first_scanned']
        result[id]['last_scanned'] = app['last_scanned']
      }
    end

    # crutch :fortune_rank do |collection|
    #   data = IosAppsWebsite.joins(:website => :company).where(ios_app_id: collection.map(&:id)).pluck(:ios_app_id, :fortune_1000_rank)
    #   data.each.with_object({}) { |(id, rank), result| result[id] ||= rank }
    # end

    crutch :categories do |collection|
      data = IosAppCategory.joins(:ios_app_current_snapshots).where('ios_app_current_snapshots.ios_app_id' => collection.map(&:id), 'ios_app_categories_current_snapshots.kind' => 0).pluck('ios_app_current_snapshots.ios_app_id', 'ios_app_categories.name')
      data.each.with_object({}) { |(id, name), result| (result[id] ||= []).push(name); result[id].uniq! }
    end

    crutch :headquarters do |collection|
      data = ::IosApp.where(id: collection.map(&:id)).joins(:ios_developer => [{:valid_websites => :domain_datum}]).
             pluck(:id, :street_number, :street_name, :sub_premise, :city, :postal_code, :state, :state_code, :country, :country_code, :lat, :lng)
      data.each.with_object({}) { |(id, street_number, street_name, sub_premise, city, postal_code, state, state_code, country, country_code, lat, lng), result|
        result[id] ||= []
        result[id] << {
          street_number: street_number,
          street_name: street_name,
          sub_premise: sub_premise,
          city: city,
          postal_code: postal_code,
          state: state,
          state_code: state_code,
          country: country,
          country_code: country_code,
          lat: lat,
          lng: lng
        }
        result[id].uniq!
      }
    end

    field :id
    field :app_identifier, index: 'not_analyzed'
    field :name, type: 'string', value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'name') } do
      field :lowercase, analyzer: 'lowercase'
    end
    field :seller_url, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'seller_url') }
    field :seller, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'seller_name') }
    field :user_base, index: 'not_analyzed'
    field :user_bases, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'user_bases') }, type: 'nested', include_in_parent: true do
      field :country_code, index: 'not_analyzed'
      field :user_base, index: 'not_analyzed'
      field :country, index: 'not_analyzed'
    end

    field :old_facebook_ads, value: ->(app, crutches) { crutches.old_ad_spend[app.id].present? }
    field :facebook_ads, value: ->(app, crutches) { crutches.ad_spend[app.id].present? }
    field :first_seen_ads, value: ->(app, crutches) { crutches.ad_spend[app.id].try(:[], 'first_seen_ads')  }, type: 'date', format: 'date_time', include_in_all: false
    field :last_seen_ads, value: ->(app, crutches) { crutches.ad_spend[app.id].try(:[], 'last_seen_ads')  }, type: 'date', format: 'date_time', include_in_all: false

    field :first_scanned, value: ->(app, crutches) { crutches.scanned_date[app.id].try(:[], 'first_scanned')  }, type: 'date', format: 'date_time', include_in_all: false
    field :last_scanned, value: ->(app, crutches) { crutches.scanned_date[app.id].try(:[], 'last_scanned')  }, type: 'date', format: 'date_time', include_in_all: false

    field :paid, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'price').to_f > 0 }
    field :in_app_purchases, value: ->(ios_app) {ios_app.newest_ios_app_snapshot.try(:ios_in_app_purchases).try(:any?)}
    field :mobile_priority, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'mobile_priority') }, index: 'not_analyzed'
    field :categories, value: ->(app, crutches) { crutches.categories[app.id] }, index: 'not_analyzed'
    field :ratings_all, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'ratings_all').to_i }, type: 'integer'

    field :daily_active_users_num, value: -> (ios_app){ios_app.daily_active_users}, type: 'long'
    field :daily_active_users_rank, type: 'integer'
    field :monthly_active_users_num, value: -> (ios_app){ios_app.monthly_active_users}, type: 'long'
    field :monthly_active_users_rank, type: 'integer'
    field :weekly_active_users_num, value: -> (ios_app){ios_app.weekly_active_users}, type: 'long'

    field :installed_sdks, type: 'nested', include_in_parent: true do
      field :id
      field :name
      field :website
      field :favicon
      field :first_seen_date, type: 'date', format: 'date_time', include_in_all: false
      field :last_seen_date, type: 'date', format: 'date_time', include_in_all: false
    end
    field :uninstalled_sdks, type: 'nested', include_in_parent: true do
      field :id
      field :name
      field :website
      field :favicon
      field :first_seen_date, type: 'date', format: 'date_time', include_in_all: false
      field :last_seen_date, type: 'date', format: 'date_time', include_in_all: false
    end

    field :app_stores, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'app_stores') }, type: 'nested', include_in_parent: true do
      field :name, index: 'not_analyzed'
      field :country_code, index: 'not_analyzed'
    end
    field :app_stores_count, type: 'integer', value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'app_stores').try(:size) }
    field :publisher_id, value: -> (ios_app){ios_app.ios_developer.try(:id)}
    field :publisher_identifier, value: -> (ios_app){ios_app.ios_developer.try(:identifier)}, index: 'not_analyzed'
    field :publisher_name, type: 'string', value: -> (ios_app){ios_app.ios_developer.try(:name)} do
      field :lowercase, analyzer: 'lowercase'
    end
    field :fortune_rank, value: -> (ios_app){ios_app.ios_developer.try(:fortune_1000_rank)}, type: 'integer'
    field :publisher_websites, value: -> (ios_app){ios_app.ios_developer.try(:get_valid_website_urls)}, index: 'not_analyzed'

    field :headquarters, value: ->(app, crutches) { crutches.headquarters[app.id] || []}, type: 'nested', include_in_parent: true do
      field :street_number, index: 'not_analyzed'
      field :street_name, index: 'not_analyzed'
      field :sub_premise, index: 'not_analyzed'
      field :city, index: 'not_analyzed'
      field :postal_code, index: 'not_analyzed'
      field :state, index: 'not_analyzed'
      field :state_code, index: 'not_analyzed'
      field :country, index: 'not_analyzed'
      field :country_code, index: 'not_analyzed'
      field :lat, type: 'float'
      field :lng, type: 'float'
    end
    field :last_updated, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'last_updated') }, type: 'date', format: 'date', include_in_all: false
    field :released, value: ->(app, crutches) { crutches.current_snapshot[app.id].try(:[], 'first_released') }, type: 'date', format: 'date', include_in_all: false
  end


  define_type AndroidApp.includes(:newest_android_app_snapshot, :android_developer) do

    crutch :old_ad_spend do |collection|
      data = AndroidFbAdAppearance.where(android_app_id: collection.map(&:id)).pluck(:android_app_id).uniq
      data.each.with_object({}) { |(id), result| result[id] = true }
    end

    crutch :ad_spend do |collection|
      data = AndroidAd.where(advertised_app_id: collection.map(&:id)).
      group(:advertised_app_id).select('advertised_app_id', 'max(date_seen) as last_seen_ads', 'min(date_seen) as first_seen_ads')
      data.each.with_object({}) { |(app), result|
        id = app['advertised_app_id']
        result[id] ||= {}
        result[id]['first_seen_ads'] = app['first_seen_ads']
        result[id]['last_seen_ads'] = app['last_seen_ads']
      }
    end

    # crutch :fortune_rank do |collection|
    #   data = AndroidAppsWebsite.joins(:website => :company).where(android_app_id: collection.map(&:id)).pluck(:android_app_id, :fortune_1000_rank)
    #   data.each.with_object({}) { |(id, rank), result| result[id] ||= rank }
    # end

    crutch :categories do |collection|
      data = AndroidAppCategory.joins(:android_app_snapshots).where('android_app_snapshots.android_app_id' => collection.map(&:id), 'android_app_categories_snapshots.kind' => 0).
                                order('android_app_snapshots.created_at DESC').pluck('android_app_snapshots.android_app_id', 'android_app_categories.name')
      data.each.with_object({}) { |(id, name), result| result[id] ||= name }
    end

    crutch :scanned_date do |collection|
      data = ApkSnapshot.where(android_app_id: collection.map(&:id)).where("scan_status = ? OR status = ?", ApkSnapshot.scan_statuses[:scan_success], ApkSnapshot.scan_statuses[:scan_success]).
      group(:android_app_id).select('android_app_id', 'max(good_as_of_date) as last_scanned', 'min(good_as_of_date) as first_scanned')
      data.each.with_object({}) { |(app), result|
        id = app['android_app_id']
        result[id] ||= {}
        result[id]['first_scanned'] = app['first_scanned']
        result[id]['last_scanned'] = app['last_scanned']
      }
    end

    crutch :headquarters do |collection|
      data = ::AndroidApp.where(id: collection.map(&:id)).joins(:android_developer => [{:valid_websites => :domain_datum}]).
             pluck(:id, :street_number, :street_name, :sub_premise, :city, :postal_code, :state, :state_code, :country, :country_code, :lat, :lng)
      data.each.with_object({}) { |(id, street_number, street_name, sub_premise, city, postal_code, state, state_code, country, country_code, lat, lng), result|
        result[id] ||= []
        result[id] << {
          street_number: street_number,
          street_name: street_name,
          sub_premise: sub_premise,
          city: city,
          postal_code: postal_code,
          state: state,
          state_code: state_code,
          country: country,
          country_code: country_code,
          lat: lat,
          lng: lng
        }
        result[id].uniq!
      }
    end

    field :id
    field :app_identifier, index: 'not_analyzed'
    field :name, type: 'string', value: ->(android_app) {android_app.newest_android_app_snapshot.try(:name) || ''} do
      field :lowercase, analyzer: 'lowercase'
    end
    field :seller_url, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:seller_url) || ''}
    field :seller, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:seller) || ''}
    field :user_base, index: 'not_analyzed'
    field :ratings_all, value: ->(android_app) { android_app.newest_android_app_snapshot.try(:ratings_all_count).to_i }, type: 'integer'
    field :facebook_ads, value: ->(app, crutches) { crutches.ad_spend[app.id].present? }
    field :paid, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:price).to_f > 0 }
    field :in_app_purchases, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:in_app_purchase_min).present?}
    field :mobile_priority, index: 'not_analyzed'
    field :categories, value: ->(app, crutches) { [crutches.categories[app.id]].compact }, index: 'not_analyzed'
    field :downloads_min, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:downloads_min)}
    field :downloads_max, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:downloads_max)}

    field :first_scanned, value: ->(app, crutches) { crutches.scanned_date[app.id].try(:[], 'first_scanned')  }, type: 'date', format: 'date_time', include_in_all: false
    field :last_scanned, value: ->(app, crutches) { crutches.scanned_date[app.id].try(:[], 'last_scanned')  }, type: 'date', format: 'date_time', include_in_all: false

    field :installed_sdks, type: 'nested', include_in_parent: true do
      field :id
      field :name
      field :website
      field :favicon
      field :first_seen_date, type: 'date', format: 'date_time', include_in_all: false
      field :last_seen_date, type: 'date', format: 'date_time', include_in_all: false
    end
    field :uninstalled_sdks, type: 'nested', include_in_parent: true do
      field :id
      field :name
      field :website
      field :favicon
      field :first_seen_date, type: 'date', format: 'date_time', include_in_all: false
      field :last_seen_date, type: 'date', format: 'date_time', include_in_all: false
    end
    field :publisher_id, value: -> (android_app){android_app.android_developer.try(:id)}
    field :publisher_identifier, value: -> (android_app){android_app.android_developer.try(:identifier)}, index: 'not_analyzed'
    field :publisher_name, type: 'string', value: -> (android_app){android_app.android_developer.try(:name)} do
      field :lowercase, analyzer: 'lowercase'
    end
    field :fortune_rank, value: -> (android_app){android_app.android_developer.try(:fortune_1000_rank)}, type: 'integer'
    field :publisher_websites, value: -> (android_app){android_app.android_developer.try(:get_valid_website_urls)}, index: 'not_analyzed'

    field :headquarters, value: ->(app, crutches) { crutches.headquarters[app.id] || []}, type: 'nested', include_in_parent: true do
      field :street_number, index: 'not_analyzed'
      field :street_name, index: 'not_analyzed'
      field :sub_premise, index: 'not_analyzed'
      field :city, index: 'not_analyzed'
      field :postal_code, index: 'not_analyzed'
      field :state, index: 'not_analyzed'
      field :state_code, index: 'not_analyzed'
      field :country, index: 'not_analyzed'
      field :country_code, index: 'not_analyzed'
      field :lat, type: 'float'
      field :lng, type: 'float'
    end
    field :last_updated, type: 'date', format: 'date', include_in_all: false
  end
end
