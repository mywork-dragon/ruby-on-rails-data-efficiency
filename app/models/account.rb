class Account < ActiveRecord::Base
  
  has_many :users
  
  has_many :api_keys

  def active_users
    self.users.where(access_revoked: false).size
  end

  def as_json(options={})
    super().merge(:users => self.users.as_json, type: self.class.name, active_users: self.active_users)
  end
  
end
