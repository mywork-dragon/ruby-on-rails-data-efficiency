class RankingsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  def get_android_category_objects
    ra = RankingsAccessor.new
    render json: AndroidAppCategory.where(category_id: ra.android_categories)
  end

  def get_ios_category_objects
    ra = RankingsAccessor.new
    render json: IosAppCategory.where(category_identifier: ra.ios_categories)
  end
end
