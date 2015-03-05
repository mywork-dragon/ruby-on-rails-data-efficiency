class AddFortune1000Service

  class << self
    
    def run
      
      CSV.foreach("db/fortune/fortune1000-2014.csv", headers: true) do |row|
        
        website = UrlManipulator.url_with_http_only(row[4])
        c = Company.find_by_website(website)
        
        if c.nil?
          c = Company.new
          c.website = website
        end
        
        c.name = row[0]
        c.fortune_1000_rank = row[1].to_i
        c.ceo_name = row[3]
        c.street_address = row[5]
        c.city = row[6]
        c.zip_code = row[7]
        c.state = row[8]

        c.save!
      end
      
    end
    
  end

end