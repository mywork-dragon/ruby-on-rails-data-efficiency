class AuthService
  
  class << self
    
    def token_valid?(token)
      
      #TODO: logic
      
      false
      
    end

    def create_accounts(account_name, *emails)
      account = Account.find_or_initialize_by(name: account_name)
      if account.new_record?
        account.can_view_support_desk = false
        account.can_view_ad_spend = true
        account.can_view_sdks = true
        account.can_view_storewide_sdks = true
        account.can_view_exports = false
        account.can_view_ios_live_scan = true
        account.save
      end

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