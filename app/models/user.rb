class User < ActiveRecord::Base

  has_secure_password
  validates_uniqueness_of :email

  def generate_auth_token
    payload = { user_id: self.id }
    AuthToken.encode(payload)
  end

end
