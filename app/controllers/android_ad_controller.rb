class AndroidAdController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin

  def create
    ad = AndroidAd.find_or_initialize_by(ad_id: params['ad_id'])

    ad.ad_type = params['ad_type'].to_sym
    ad.android_device_sn = params['android_device_sn']
    ad.ad_id = params['ad_id']
    ad.source_app = AndroidApp.find_by_app_identifier(params['source_app_identifier'])

    ad.advertised_app_identifier = params['advertised_app_identifier']
    ad.advertised_app = AndroidApp.find_by_app_identifier(params['advertised_app_identifier'])
    ad.google_account = params['google_account']
    ad.facebook_account = params['facebook_account']
    ad.ad_text = params['ad_text']


    ad.target_location = params['target_location']
    ad.target_max_age = params['target_max_age']
    ad.target_min_age = params['target_min_age']
    ad.target_similar_to_existing_users = params['target_similar_to_existing_users']
    ad.target_gender = params['target_gender']
    ad.target_education = params['target_education']
    ad.target_existing_users = params['target_existing_users']
    ad.target_facebook_audience = params['target_facebook_audience']
    ad.target_language = params['target_language']
    ad.target_relationship_status = params['target_relationship_status']
    if params['target_interests'].present?
      ad.target_interests = params['target_interests'].split('|')
    end
    ad.target_proximity_to_business = params['target_proximity_to_business']
    ad.save!

    render json: { success: true }, status: 200
  end

end
