class ApiKey < ActiveRecord::Base

  validates :key, presence: true
  validates :key, uniqueness: true

  has_many :accounts_api_keys
  has_many :accounts, through: :accounts_api_keys

  class << self
    
    # Create a unique API key
    # @author Jason Lew
    def create!
      loop do 
        key = SecureRandom.urlsafe_base64
        if !ApiKey.find_by_key(key)
          super(key: key)
          break
        end
      end 
    end
    
  end

end
