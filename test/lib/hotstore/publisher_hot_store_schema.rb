module PublisherHotStoreSchema

  def publisher_schema
    @@PUBLISHER_SCHEMA
  end

  @@DETAIL_SCHEMA = {
      "name"=> String,
      "legal_name"=> String,
      "domain"=> String,
      "description"=> String,
      "company_type"=> String,
      "tags"=> [ String ],
      "sector"=> String,
      "industry_group"=> String,
      "industry"=> String,
      "sub_industry"=> String,
      "tech_used"=> [ String ],
      "founded_year"=> Integer,
      "time_zone"=> String,
      "utc_offset"=> Integer,
      "street_number"=> String,
      "street_name"=> String,
      "sub_premise"=> String,
      "city"=> String,
      "postal_code"=> String,
      "state"=> String,
      "state_code"=> String,
      "country"=> String,
      "country_code"=> String,
      "lat"=> String,
      "lng"=> String,
      "logo_url"=> String,
      "facebook_handle"=> String,
      "linkedin_handle"=> String,
      "twitter_handle"=> String,
      "twitter_id"=> String,
      "crunchbase_handle"=> String,
      "email_provider"=> TrueClass,
      "ticker"=> String,
      "phone"=> String,
      "alexa_us_rank"=> Integer,
      "alexa_global_rank"=> Integer,
      "google_rank"=> Integer,
      "employees"=> Integer,
      "employees_range"=> String,
      "market_cap"=> Integer,
      "raised"=> Integer,
      "annual_revenue"=> Integer,
      "fortune_1000_rank"=> Integer
    }

  @@APP_SCHEMA = {
    "id" => Integer,
    "platform" => String
  }

  @@PUBLISHER_SCHEMA = {
    # "details" => [ @@DETAIL_SCHEMA ],
    "publisher_identifier" => String,
    "name" => String,
    "id" => Integer,
    "platform" => String,
    "apps" => [@@APP_SCHEMA],
    "websites" => [ String ]
  }

end
