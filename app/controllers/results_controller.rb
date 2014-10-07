class ResultsController < ApplicationController

  http_basic_authenticate_with :name => "mister", :password => "stocking"

  def companies
    company_ids = Installation.select("distinct company_id").map(&:company_id)
    @companies = Company.where(id: company_ids)
  end

  def services
    services_ids = Installation.select("distinct service_id").map(&:service_id)
    @services = Service.where(id: services_ids)
  end

  def service_result
    @service = Service.find(params[:service_id])
    @matched = @service.installations.group(:company_id).select("distinct company_id, max(created_at) as created_at, status").includes(:company).group_by(&:status)
  end

  def company_result
    @company = Company.find(params[:company_id])
    # we only need to select one distinct service id and last matched date
    @matched = @company.installations.group(:service_id).select("distinct service_id, max(created_at) as created_at, status").includes(:service).group_by(&:status)
  end

  def url_search
    
  end

  def url_search_result
    @url = params[:url]
    @url = @url.match(/^http[s]*:\/\//) ? @url : "http://" + @url
    @results = ScrapeService.scrape_test(@url)
  end

end
