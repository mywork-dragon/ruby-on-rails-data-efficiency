class Account < ActiveRecord::Base
  
  has_many :users
  
  has_many :api_keys

  has_many :api_tokens

  def active_users
    self.users.where(access_revoked: false).size
  end

  def generate_api_token
    # if token exists, confirm they want this to happen
    # rate limit
    # period
    if api_tokens.any?
      ap api_tokens
      print 'An API token for this account already exists. Continue [y/n]? : '
      return unless gets.chomp.include?('y')
    end

    puts '-------------------------'
    puts 'Set rate limit parameters'
    puts '-------------------------'

    ApiToken.rate_windows.each { |k,v| puts "#{v}: #{k}" }
    print 'Which window would you like? Enter a number [default is 0]: '
    window = gets.strip.to_i

    print 'How many requests during that time frame would you like? Enter a number [default is 2500]: '
    limit = gets.strip.to_i
    limit = limit == 0 ? limit = 2500 : limit
    
    puts '-------------------------'
    puts "Rate Window: #{ApiToken.rate_windows.invert[window]}"
    puts "Limit: #{limit} requests / window"
    print 'Is this correct? [y/n]: '
    return unless gets.chomp.include?('y')

    token = ApiToken.create!(
      account_id: id,
      token: SecureRandom.hex,
      rate_window: window,
      rate_limit: limit
    )

    puts '-------------------------'
    puts 'New API Token'
    ap token
  end

  def as_json(options={})
    super().merge(:users => self.users.as_json, type: self.class.name, active_users: self.active_users)
  end
  
end
