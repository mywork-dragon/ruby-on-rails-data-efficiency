class MightySignalSalesforceController < ApplicationController

  def hydrate_lead
    return if params[:key] != 'Xb06g1lmGWmRiWzrcA3MUA'
    
    json = {"mighty_signal_sf_hydrate_lead" => "success"}
    
    render json: json
    
    MightySignalSalesforceService.hydrate_lead(params[:lead])
    
  end
  
  def hydrate_opp
    return if params[:key] != 'n0rJyo2wYMmCIt7NjkYH1A'
    
    json = {"mighty_signal_sf_hydrate_opp" => "success"}
    
    render json: json
    
    MightySignalSalesforceService.hydrate_opp(params[:opportunity])
    
  end

end
