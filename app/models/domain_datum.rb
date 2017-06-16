class DomainDatum < ActiveRecord::Base
  has_many :websites, through: :websites_domain_data
  has_many :websites_domain_data
  has_many :clearbit_contacts

  serialize :tech_used, Array
  serialize :tags, Array

  def populate(company_data)
    company_data = company_data.with_indifferent_access
    self.clearbit_id = company_data["id"] if company_data["id"]
    self.name = company_data["name"] if company_data["name"]
    self.legal_name = company_data["legalName"] if company_data["legalName"]
    self.tags = company_data["tags"] if company_data["tags"]
    self.description = company_data["description"] if company_data["description"]
    self.founded_year = company_data["foundedYear"] if company_data["foundedYear"]
    self.sector = company_data["category"].try(:[], :sector) if company_data["category"].try(:[], :sector)
    self.industry_group = company_data["category"].try(:[], :industryGroup) if company_data["category"].try(:[], :industryGroup)
    self.industry = company_data["category"].try(:[], :industry) if company_data["category"].try(:[], :industry)
    self.sub_industry = company_data["category"].try(:[], :subIndustry) if company_data["category"].try(:[], :subIndustry)
    self.time_zone = company_data["timeZone"] if company_data["timeZone"]
    self.utc_offset = company_data["utcOffset"] if company_data["utcOffset"]
    self.street_number = company_data["geo"].try(:[], :streetNumber) if company_data["geo"].try(:[], :streetNumber)
    self.street_name = company_data["geo"].try(:[], :streetName) if company_data["geo"].try(:[], :streetName)
    self.sub_premise = company_data["geo"].try(:[], :subPremise) if company_data["geo"].try(:[], :subPremise)
    self.city = company_data["geo"].try(:[], :city) if company_data["geo"].try(:[], :city)
    self.postal_code = company_data["geo"].try(:[], :postalCode) if company_data["geo"].try(:[], :postalCode)
    self.state = company_data["geo"].try(:[], :state) if company_data["geo"].try(:[], :state)
    self.state_code = company_data["geo"].try(:[], :stateCode) if company_data["geo"].try(:[], :stateCode)
    self.country = company_data["geo"].try(:[], :country) if company_data["geo"].try(:[], :country)
    self.country_code = company_data["geo"].try(:[], :countryCode) if company_data["geo"].try(:[], :countryCode)
    self.lat = company_data["geo"].try(:[], :lat) if company_data["geo"].try(:[], :lat)
    self.lng = company_data["geo"].try(:[], :lng) if company_data["geo"].try(:[], :lng)
    self.logo_url = company_data["logo"] if company_data["logo"]
    self.facebook_handle = company_data["facebook"].try(:[], :handle) if company_data["facebook"].try(:[], :handle)
    self.linkedin_handle = company_data["linkedin"].try(:[], :handle) if company_data["linkedin"].try(:[], :handle)
    self.twitter_handle = company_data["twitter"].try(:[], :handle) if company_data["twitter"].try(:[], :handle)
    self.twitter_id = company_data["twitter"].try(:[], :id) if company_data["twitter"].try(:[], :id)
    self.crunchbase_handle = company_data["crunchbase"].try(:[], :handle) if company_data["crunchbase"].try(:[], :handle)
    self.email_provider = company_data["emailProvider"] if company_data["emailProvider"]
    self.company_type = company_data["type"] if company_data["type"]
    self.ticker = company_data["ticker"] if company_data["ticker"]
    self.phone = company_data["phone"] if company_data["phone"]
    self.alexa_us_rank = company_data["metrics"].try(:[], :alexaUsRank) if company_data["metrics"].try(:[], :alexaUsRank)
    self.alexa_global_rank = company_data["metrics"].try(:[], :alexaGlobalRank) if company_data["metrics"].try(:[], :alexaGlobalRank)
    self.employees = company_data["metrics"].try(:[], :employees) if company_data["metrics"].try(:[], :employees)
    self.employees_range = company_data["metrics"].try(:[], :employeesRange) if company_data["metrics"].try(:[], :employeesRange)
    self.market_cap = company_data["metrics"].try(:[], :marketCap) if company_data["metrics"].try(:[], :marketCap)
    self.raised = company_data["metrics"].try(:[], :raised) if company_data["metrics"].try(:[], :raised)
    self.annual_revenue = company_data["metrics"].try(:[], :annualRevenue) if company_data["metrics"].try(:[], :annualRevenue)
    self.tech_used = company_data["tech"] if company_data["tech"]
    self.save
  end

  def as_json(_options = {})
    super(except: [:clearbit_id, :created_at, :updated_at, :id])
  end
end
