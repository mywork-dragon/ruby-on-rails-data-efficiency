class BizibleSalesforceController < ApplicationController

  protect_from_forgery except: [:hydrate_lead, :hydrate_opp]

  def hydrate_lead
    puts "bizible_sf_hydrate_lead called"
    
    json = {"bizible_sf_hydrate_lead" => "success"}
    
    render json: json
    
    BizibleSalesforceService.hydrate_lead(params[:lead])
    
  end
  
  def hydrate_opp
    puts "bizible_sf_hydrate_opp called"
    
    json = {"bizible_sf_hydrate_opp" => "success"}
    
    render json: json
    
    BizibleSalesforceService.hydrate_opp(params[:opportunity])
    
  end

end
