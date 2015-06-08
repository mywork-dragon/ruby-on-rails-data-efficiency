class JpIosAppSnapshot < ActiveRecord::Base
  
  enum user_base: [:elite, :strong, :moderate, :weak]
  enum mobile_priority: [:high, :medium, :low]
  
end
