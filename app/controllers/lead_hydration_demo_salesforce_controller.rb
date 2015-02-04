class LeadHydrationDemoSalesforceController < ApplicationController

  protect_from_forgery except: [:hydrate_lead]


  def hydrate_lead
    puts "demo_sf_hydrate_lead called"
    
    return if params[:key] != 'asfklnas2412SFFSS'
    
    json = {"demo_sf_hydrate_lead" => "success"}
    
    render json: json
    
    LeadHydrationDemoSalesforceService.hydrate_lead(params[:lead])
    
  end

end
