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
    field :name, :seller_url
    # field :seller_url, value: ->(url) {UrlHelper.url_with_domain_only(url)}
    field :company_name, value: ->(ios_app_snapshot) {!(ios_app_snapshot.ios_app.nil? || ios_app_snapshot.ios_app.get_company.nil?) ? ios_app_snapshot.ios_app.get_company.name : ''}
  end

  define_type AndroidAppSnapshot do
    field :name, :seller_url
    # field :seller_url, value: ->(url) {UrlHelper.url_with_domain_only(url)}
    field :company_name, value: ->(android_app_snapshot) {!(android_app_snapshot.android_app.nil? || android_app_snapshot.android_app.get_company.nil?) ? android_app_snapshot.android_app.get_company.name : ''}
    # Seller URL
    # Seller
  end

end
