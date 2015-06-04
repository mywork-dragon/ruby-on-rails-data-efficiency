class OptimalAccountService
  
  class << self
  
    def calc
      
    	total_apps = 1273000

      seconds_in_a_day = 86400

      allowed_downloads_per_day = 1400

      average_download_time = 60

      threads = 100

      accounts_per_day = ((seconds_in_a_day/(allowed_downloads_per_day * average_download_time).to_f)*threads).to_i

      number_of_days = total_apps/(accounts_per_day * allowed_downloads_per_day)

      puts "Accounts: #{accounts_per_day}\n"

      puts "Days: #{number_of_days}"
      
    end
  
  end
  
end