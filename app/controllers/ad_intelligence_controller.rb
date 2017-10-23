class AdIntelligenceController < ApplicationController

  skip_before_filter  :verify_authenticity_token

  before_action :set_current_user, :authenticate_request
  before_action :authenticate_ad_intelligence

  def available_sources
    render json: AdDataAccessor.new.available_sources(@current_user.account)
  end

  def ad_intelligence_query
    page_size = [params[:pageSize] ? params[:pageSize].to_i : 20, AdDataAccessor::MAX_PAGE_SIZE].min
    page_num = params[:pageNum] ? params[:pageNum].to_i : 0
    params[:sortBy] ||= 'first_seen_ads_date'
    order_by = ['desc', 'asc'].include?(params[:orderBy]) ? params[:orderBy] : 'desc'

    results = AdDataAccessor.new.query(
      @current_user.account,
      platforms: params[:platforms],
      source_ids: params[:sourceIds],
      sort_by: params[:sortBy],
      order_by: order_by,
      page_size: page_size,
      page_number: page_num)

    respond_to do |format|
      format.json { render json:
        {
          results: results,
          resultsCount: results.count,
          pageNum: page_num,
          pageSize: page_size
        }
      }
      # TO DO IMPLEMENT CSV
      #format.csv { render_csv(apps: results) }
    end
  end
end
