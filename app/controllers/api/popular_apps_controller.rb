class Api::PopularAppsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_action :set_current_user, :authenticate_request

  def newcomers
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 50).to_i
    countries = params[:countries] || []
    categories = params[:categories] || []
    rank_types = params[:rank_types] || ["free", "paid", "grossing"]
    platforms = params[:platforms] || []
    max_rank = params[:max_rank] || 500

    trending = RankingsAccessor.new.get_newcomers(categories: categories,
                                                  countries: countries,
                                                  rank_types: rank_types,
                                                  platforms: platforms,
                                                  size: per_page, 
                                                  page_num: page,
                                                  max_rank: max_rank
                                                )

    apps = enrich_trending(trending)

    render json: {apps: apps.uniq, total: trending['total']}
  end

  def trending

    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 50).to_i
    order = params[:orderBy] || 'desc'
    sort = params[:sortBy] || 'weekly_change'

    countries = params[:countries] || []
    categories = params[:categories] || []
    rank_types = params[:rank_types] || ["free", "paid", "grossing"]
    platforms = params[:platforms] || []
    max_rank = params[:max_rank] || 500

    trending = RankingsAccessor.new.get_trending(countries: countries, 
                                                 categories: categories,
                                                 rank_types: rank_types,
                                                 platforms: platforms,
                                                 size: per_page, 
                                                 sort_by: sort,
                                                 desc: order == 'desc',
                                                 page_num: page,
                                                 max_rank: max_rank
                                                )
    apps = enrich_trending(trending)

    render json: {apps: apps.uniq, total: trending['total']}
  end

  def top_app_chart
    platform = params[:platform]
    country = params[:country]
    category = params[:category]
    page_num = params[:page_num] || 1
    rank_type = params[:rank_type]
    size = params[:size] || 50

    trending = RankingsAccessor.new.get_chart(
                                   platform: platform,
                                   size: size.to_i,
                                   rank_type: rank_type,
                                   country: country,
                                   category: category,
                                   page_num: page_num.to_i
                                  )

    apps = enrich_trending(trending)

    render json: {apps: apps.uniq, total: trending['total']}
  end

  private 

  def enrich_trending(trending)
    apps = []
    trending["apps"].each do |rank| 
      if rank["platform"] == 'ios'
        app_class = IosApp
        rank['category_name'] = IosAppCategory.find_by_category_identifier(rank['category']).try(:name)
      else
        app_class = AndroidApp
        rank['category_name'] = AndroidAppCategory.find_by_category_id(rank['category']).try(:name)
      end
      app_json = app_class.find_by_app_identifier(rank["app_identifier"]).as_json || {}
      app_json[:trending] = rank
      apps << app_json
    end
    apps
  end

end