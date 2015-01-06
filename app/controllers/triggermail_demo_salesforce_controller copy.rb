class TriggermailDemoSalesforceController < ApplicationController

  protect_from_forgery except: [:hydrate_lead, :hydrate_opp]
  
  force_ssl only: :salesforce_credentials

  def hydrate_lead
    puts "triggermail_sf_hydrate_lead called"
    
    return if params[:key] != 'alksnflakncsk223'
    
    json = {"triggermail_sf_hydrate_lead" => "success"}
    
    render json: json
    
    TriggermailDemoSalesforceService.hydrate_lead(params[:lead])
    
  end

end
