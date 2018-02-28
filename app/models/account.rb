class Account < ActiveRecord::Base
  include Follower
  include AdDataPermissions
  include EncryptedAttributes
  has_many :users

  has_many :api_keys

  has_many :api_tokens
  has_many :salesforce_objects

  serialize :salesforce_settings, JSON
  enum salesforce_status: [:setup, :ready]

  serialize :ad_data_permissions, JSON

  @@kms_key = ENV["SALESFORCE_KMS_KEY_ID"]

  encrypt_attribute(:salesforce_token, @@kms_key)
  encrypt_attribute(:salesforce_refresh_token, @@kms_key)

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
    {
      id:  id,
      name:  name,
      created_at:  created_at,
      updated_at:  updated_at,
      can_view_support_desk:  can_view_support_desk,
      can_view_ad_spend:  can_view_ad_spend,
      can_view_sdks:  can_view_sdks,
      can_view_storewide_sdks:  can_view_storewide_sdks,
      can_view_exports:  can_view_exports,
      is_admin_account:  is_admin_account,
      can_view_ios_live_scan:  can_view_ios_live_scan,
      seats_count:  seats_count,
      can_view_ad_attribution:  can_view_ad_attribution,
      salesforce_uid:  salesforce_uid,
      salesforce_settings:  salesforce_settings,
      mightysignal_id:  mightysignal_id,
      can_use_salesforce:  can_use_salesforce,
      salesforce_status:  salesforce_status,
      ad_data_permissions:  ad_data_permissions,
      salesforce_syncing:  salesforce_syncing,
      type: self.class.name,
      active_users: active_users,
      salesforce_connected: salesforce_uid.present?,
      api_tokens: self.api_tokens
    }
  end

  ## Salesforce Settings ##

  def domain_syncing_frequency
    (salesforce_settings.try(:with_indifferent_access) || {})[:sync_domain_mapping]
  end

  def salesforce_sandbox?
    (salesforce_settings.try(:with_indifferent_access) || {})[:is_sandbox]
  end

  def blacklist_sdk_tags(tag_ids)
    settings = salesforce_settings.try(:with_indifferent_access) || {}  
    settings[:blacklisted_sdk_tags] = tag_ids
    self.update_attributes(salesforce_settings: settings)
  end

  def blacklisted_sdk_tags
    (salesforce_settings.try(:with_indifferent_access) || {})[:blacklisted_sdk_tags]
  end

  def syncing_query(model)
    settings =  salesforce_settings.try(:with_indifferent_access)
    settings.try(:[], :syncing_queries).try(:[], model)
  end

  def set_syncing_query(model:, query:)
    settings = salesforce_settings.try(:with_indifferent_access) || {}  
    settings[:syncing_queries] ||= {}
    settings[:syncing_queries][model] = query
    self.update_attributes(salesforce_settings: settings)
  end

  def set_salesforce_tier(tier:)
    settings = salesforce_settings.try(:with_indifferent_access) || {}  
    settings[:tier] = tier
    self.update_attributes(salesforce_settings: settings)
  end

  def salesforce_tier
    (salesforce_settings.try(:with_indifferent_access) || {})[:tier] || 'basic'
  end

  def domain_mapping_query(model)
    settings =  salesforce_settings.try(:with_indifferent_access)
    settings.try(:[], :domain_mapping_queries).try(:[], model)
  end

  def set_domain_mapping_query(model:, query:)
    settings = salesforce_settings.try(:with_indifferent_access) || {}  
    settings[:domain_mapping_queries] ||= {}
    settings[:domain_mapping_queries][model] = query
    self.update_attributes(salesforce_settings: settings)
  end

  def custom_website_fields(model)
    settings = salesforce_settings.try(:with_indifferent_access) || {}  
    settings.try(:[], :custom_website_fields).try(:[], model)
  end

  def set_custom_website_fields(model:, fields:)
    settings = salesforce_settings.try(:with_indifferent_access) || {}  
    settings[:custom_website_fields] ||= {}
    settings[:custom_website_fields][model] = fields

    self.update_attributes(salesforce_settings: settings)
  end

  def set_domain_syncing(frequency:)
    # Syncs run every week or every 5 min
    raise "Unsupported frequency option" unless ['1w', '5m', nil].include?(frequency)
    settings = salesforce_settings.try(:with_indifferent_access) || {}  
    settings[:sync_domain_mapping] = frequency
    
    self.update_attributes(salesforce_settings: settings)
  end

end
