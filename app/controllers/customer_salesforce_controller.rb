class CustomerSalesforceController < ApplicationController

  force_ssl only: :salesforce_credentials

  def salesforce_credentialsforce_ssl only: :salesforce_credentials
  end
  
end
