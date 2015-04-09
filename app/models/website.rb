class Website < ActiveRecord::Base
  has_many :companies, through: :company_websites
end
