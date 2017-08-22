module ApiHelper
  def app_stores
    AppStore.enabled.order("display_priority IS NULL, display_priority ASC")
  end

  def es_ios_app_to_csv(es_app)
    es_app = es_app.attributes
    headquarters = es_app['headquarters'].first
    user_bases = es_app['user_bases']
    row = [
      es_app['id'],
      es_app['app_identifier'],
      es_app['name'],
      'IosApp',
      es_app['mobile_priority'],
      es_app['released'],
      es_app['last_updated'],
      es_app['facebook_ads'],
      es_app['first_seen_ads'],
      es_app['last_seen_ads'],
      es_app['in_app_purchases'],
      es_app['categories'].try(:join, ', '),
      es_app['publisher_id'],
      es_app['publisher_name'],
      es_app['publisher_identifier'],
      es_app['fortune_rank'],
      es_app['publisher_websites'].try(:first, 5).try(:join, ', '),
      'http://www.mightysignal.com/app/app#/app/ios/' + es_app['id'].to_s,
      es_app['publisher_id'].present? ? "http://www.mightysignal.com/app/app#/publisher/ios/#{es_app['publisher_id']}" : nil,
      es_app['ratings_all'],
      nil,
      headquarters.try(:[], 'street_number'),
      headquarters.try(:[], 'street_name'),
      headquarters.try(:[], 'city'),
      headquarters.try(:[], 'state'),
      headquarters.try(:[], 'country'),
      headquarters.try(:[], 'postal_code'),
    ]
    if user_bases
      app_stores.each do |store|
        row << user_bases.select{|user_base| user_base['country_code'] == store.country_code}.first.try(:[], 'user_base')
      end
    end
    row
  end

  def es_android_app_to_csv(es_app)
    es_app = es_app.attributes
    headquarters = es_app['headquarters'].first
    row = [
      es_app['id'],
      es_app['app_identifier'],
      es_app['name'],
      'AndroidApp',
      es_app['mobile_priority'],
      nil,
      es_app['last_updated'],
      es_app['facebook_ads'],
      es_app['first_seen_ads'],
      es_app['last_seen_ads'],
      es_app['in_app_purchases'],
      es_app['categories'].try(:join, ', '),
      es_app['publisher_id'],
      es_app['publisher_name'],
      es_app['publisher_identifier'],
      es_app['fortune_rank'],
      es_app['publisher_websites'].try(:first, 5).try(:join, ', '),
      'http://www.mightysignal.com/app/app#/app/android/' + es_app['id'].to_s,
      es_app['publisher_id'].present? ? "http://www.mightysignal.com/app/app#/publisher/android/#{es_app['publisher_id']}" : nil,
      es_app['ratings_all'],
      "#{ActionController::Base.helpers.number_to_human(es_app['downloads_min'])}-#{ActionController::Base.helpers.number_to_human(es_app['downloads_max'])}",
      headquarters.try(:[], 'street_number'),
      headquarters.try(:[], 'street_name'),
      headquarters.try(:[], 'city'),
      headquarters.try(:[], 'state'),
      headquarters.try(:[], 'country'),
      headquarters.try(:[], 'postal_code'),
    ]
    app_stores.each do |store|
      row << (store.country_code == 'US' ? es_app['user_base'] : nil)
    end
    row
  end
end
