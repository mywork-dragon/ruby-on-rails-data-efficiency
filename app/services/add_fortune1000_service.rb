class AddFortune1000Service

  class << self
    
    def run
      
      CSV.foreach("db/fortune/fortune1000-2014.csv", headers: true) do |row|
        
        name = row[0]
        fortune1000_rank = row[1].to_i
        ceo_name = row[3]
        website = UrlManipulator.url_with_http_only(row[4])
        street_address = row[5]
        city = row[6]
        state = row[7]

        puts [name, fortune1000_rank, ceo_name, website, street_address, city, state].join("\n")
        puts ""
      end
      
    end
    
  end

end