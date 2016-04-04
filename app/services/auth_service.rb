class AuthService
  
  class << self
    
    def token_valid?(token)
      
      #TODO: logic
      
      false
      
    end

    def create_accounts(account_name, *emails)
      account = Account.find_or_create_by(name: account_name)
      account.can_view_support_desk = false
      account.can_view_ad_spend = true
      account.can_view_sdks = true
      account.can_view_storewide_sdks = true
      account.can_view_exports = true
      account.can_view_ios_live_scan = true
      account.save

      accounts = []
      emails.each do |email|
        password = SecureRandom.hex(8)
        user = account.users.create(email: email, password: password)
        accounts << "Email: #{email} Password: #{password} Worked: #{user.valid?}"
      end
      accounts
    end
    
  end
  
end