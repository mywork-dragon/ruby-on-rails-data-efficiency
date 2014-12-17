class BizibleSalesforceController < ApplicationController

  protect_from_forgery except: [:hydrate_lead, :hydrate_opp]

  def hydrate_lead
    puts "bizible_sf_hydrate_lead called"
    
    return if params[:key] != 'bQWCyOXh2Q_tWX7FUXj_mg'
    
    json = {"bizible_sf_hydrate_lead" => "success"}
    
    render json: json
    
    BizibleSalesforceService.hydrate_lead(params[:lead])
    
  end
  
  def hydrate_opp
    puts "bizible_sf_hydrate_opp called"
    
    return if params[:key] != 'ACTf3xNG_d6nl54DHDp5wA'
    
    json = {"bizible_sf_hydrate_opp" => "success"}
    
    render json: json
    
    BizibleSalesforceService.hydrate_opp(params[:opportunity])
    
  end
  
  def salesforce_credentials
  end

end
