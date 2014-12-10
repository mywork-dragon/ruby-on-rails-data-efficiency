class SalesforceService
  
  def current_date_time_sf_format
    d = DateTime.now
    d.strftime("%Y-%m-%dT%H:%M:%S%:z")
  end
  
end