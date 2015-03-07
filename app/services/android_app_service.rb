class AndroidAppService
  
  class << self
  
    def attributes(google_play_url)
      
      attributes = GooglePlayService.google_play_attributes(google_play_url)
      
      seller_url = attributes[:seller_url]
      funding = CbService.cb_funding(seller_url) if seller_url
      
      attributes.merge!({funding: funding})
      
      attributes
    end
    
    
  end
end