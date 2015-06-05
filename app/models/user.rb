class User < ActiveRecord::Base

  has_and_belongs_to_many :lists

  has_secure_password
  validates_uniqueness_of :email

  def generate_auth_token
    payload = { user_id: self.id }
    AuthToken.encode(payload)
  end

  class << self
    
    # Get the user by credentials, else return nil
    # @author Jason Lew
    # @note Be careful editing this method
    def find_by_credentials(email, password)
      
      user = User.find_by_email(email)
      
      return nil if user.nil?
      
      return user if user.authenticate(password)
      
      nil
    end
    
  end

end
