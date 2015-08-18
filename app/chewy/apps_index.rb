class AppsIndex < Chewy::Index

  settings analysis: {
    analyzer: {
      title: {
        tokenizer: 'standard',
        filter: ['lowercase', 'asciifolding']
      }
    }
  }

  define_type IosAppSnapshot do
    field :name, :description, :seller, :seller_url, :copywright
    # field :seller_url, value: ->(url) {UrlHelper.url_with_domain_only(url)}
    field :company_name, value: ->(ios_app_snapshot) {ios_app_snapshot.get_company_name}
  end


  define_type AndroidAppSnapshot do
    field :name, :description, :seller, :seller_url
    # field :seller_url, value: ->(url) {UrlHelper.url_with_domain_only(url)}
    # Company Name
    # Seller URL
    # Seller
  end

end
