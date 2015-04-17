class Proxy < ActiveRecord::Base
  
  validates :private_ip, uniqueness: true
  validates :public_ip, uniqueness: true

end
