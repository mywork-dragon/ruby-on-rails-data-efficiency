class AppsIndex < Chewy::Index

  settings analysis: {
    analyzer: {
      title: {
        tokenizer: 'standard',
        filter: ['lowercase', 'asciifolding']
      }
    }
  }

  define_type IosApp.includes(:newest_ios_app_snapshot, :ios_developer) do
    
    field :id
    field :app_identifier, index: 'not_analyzed'
    field :name, value: ->(ios_app) {!ios_app.newest_ios_app_snapshot.nil? ? ios_app.newest_ios_app_snapshot.name : ''}
    field :seller_url, value: ->(ios_app) {!ios_app.newest_ios_app_snapshot.nil? ? ios_app.newest_ios_app_snapshot.seller_url : ''}
    field :seller, value: ->(ios_app) {!ios_app.newest_ios_app_snapshot.nil? ? ios_app.newest_ios_app_snapshot.seller : ''}
    field :user_base, index: 'not_analyzed'
    field :ratings_all, value: ->(ios_app) {!ios_app.newest_ios_app_snapshot.nil? ? ios_app.newest_ios_app_snapshot.ratings_all_count : 0}
    field :old_facebook_ads, value: ->(ios_app) {ios_app.old_ad_spend?}
    field :facebook_ads, value: ->(ios_app) {ios_app.ad_spend?}
    field :paid, value: ->(ios_app) {ios_app.newest_ios_app_snapshot.try(:price).to_f > 0 }
    field :in_app_purchases, value: ->(ios_app) {ios_app.newest_ios_app_snapshot.try(:ios_in_app_purchases).try(:any?)}
    field :mobile_priority, index: 'not_analyzed'
    field :fortune_rank, type: 'integer'
    field :categories, index: 'not_analyzed'
    field :installed_sdks, type: 'nested', include_in_parent: true do
      field :id
      field :name
      field :website
      field :favicon
      field :first_seen_date, type: 'date', include_in_all: false
      field :last_seen_date, type: 'date', include_in_all: false
    end
    field :uninstalled_sdks, type: 'nested', include_in_parent: true do
      field :id
      field :name
      field :website
      field :favicon
      field :first_seen_date, type: 'date', include_in_all: false
      field :last_seen_date, type: 'date', include_in_all: false
    end
    field :publisher_id, value: -> (ios_app){ios_app.ios_developer.try(:id)}
    field :publisher_identifier, value: -> (ios_app){ios_app.ios_developer.try(:identifier)}, index: 'not_analyzed'
    field :publisher_name, value: -> (ios_app){ios_app.ios_developer.try(:name)}
    field :last_updated, type: 'date', include_in_all: false
    field :released, type: 'date', include_in_all: false
  end

  define_type AndroidApp.includes(:newest_android_app_snapshot, :android_developer) do

    field :id
    field :app_identifier, index: 'not_analyzed'
    field :name, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:name) || ''}
    field :seller_url, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:seller_url) || ''}
    field :seller, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:seller) || ''}
    field :user_base, index: 'not_analyzed'
    field :ratings_all, value: ->(android_app) { android_app.newest_android_app_snapshot.try(:ratings_all_count).to_i }
    field :facebook_ads, value: ->(android_app) {android_app.old_ad_spend?}
    field :paid, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:price).to_f > 0 }
    field :in_app_purchases, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:in_app_purchase_min).present?}
    field :mobile_priority, index: 'not_analyzed'
    field :fortune_rank, type: 'integer'
    field :categories, index: 'not_analyzed'
    field :downloads_min, value: ->(android_app) {android_app.newest_android_app_snapshot.try(:downloads_min)}
    field :installed_sdks, type: 'nested', include_in_parent: true do
      field :id
      field :name
      field :website
      field :favicon
      field :first_seen_date, type: 'date', include_in_all: false
      field :last_seen_date, type: 'date', include_in_all: false
    end
    field :uninstalled_sdks, type: 'nested', include_in_parent: true do
      field :id
      field :name
      field :website
      field :favicon
      field :first_seen_date, type: 'date', include_in_all: false
      field :last_seen_date, type: 'date', include_in_all: false
    end
    field :publisher_id, value: -> (android_app){android_app.android_developer.try(:id)}
    field :publisher_identifier, value: -> (android_app){android_app.android_developer.try(:identifier)}, index: 'not_analyzed'
    field :publisher_name, value: -> (android_app){android_app.android_developer.try(:name)}
    field :last_updated, type: 'date', include_in_all: false
  end
end
