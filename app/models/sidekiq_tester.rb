class SidekiqTester < ActiveRecord::Base
  
  class << self
    
    def say_hi
      create!(test_string: "hi", ip: MyIp.ip)
    end
    
  end
  
end
