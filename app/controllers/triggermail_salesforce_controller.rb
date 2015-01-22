class TriggermailSalesforceController < ApplicationController
  
  protect_from_forgery except: [:hydrate_lead, :hydrate_opp]
  
  force_ssl only: :salesforce_credentials

  def hydrate_lead
    puts "triggermail_sf_hydrate_lead called"
    
    return if params[:key] != '2ccc65ae1180e250ad060b988a7f07ca'
    
    json = {"triggermail_sf_hydrate_lead" => "success"}
    
    render json: json
    
    #TriggermailSalesforceService.hydrate_lead(params[:lead])
    
  end
  
  def hydrate_contact
    puts "triggermail_sf_hydrate_contact called"
    
    return if params[:key] != 'fa0ab76a976d7b96eeaf6e4e0aade99f'
    
    json = {"triggermail_sf_hydrate_contact" => "success"}
    
    render json: json
    
    TriggermailSalesforceService.hydrate_contact(params[:lead])
    
  end
  
  def hydrate_account
    puts "triggermail_sf_hydrate_account called"
    
    return if params[:key] != '90361f730c2597e64d590c9aff6693ff'
    
    json = {"triggermail_sf_hydrate_contact" => "success"}
    
    render json: json
    
    TriggermailSalesforceService.hydrate_account(params[:lead])
    
  end
  
  
end
