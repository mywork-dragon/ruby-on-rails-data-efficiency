class AppsIndex < Chewy::Index

  settings analysis: {
    analyzer: {
      title: {
        tokenizer: 'standard',
        filter: ['lowercase', 'asciifolding']
      }
    }
  }

  define_type IosApp do
    field :name, value: ->(ios_app) {!ios_app.newest_ios_app_snapshot.nil? ? ios_app.newest_ios_app_snapshot.name : ''}
    field :seller_url, value: ->(ios_app) {!ios_app.newest_ios_app_snapshot.nil? ? ios_app.newest_ios_app_snapshot.seller_url : ''}
    field :seller, value: ->(ios_app) {!ios_app.newest_ios_app_snapshot.nil? ? ios_app.newest_ios_app_snapshot.seller : ''}
    field :ratings_all, value: ->(ios_app) {!ios_app.newest_ios_app_snapshot.nil? ? ios_app.newest_ios_app_snapshot.ratings_all_count : 0}
    field :company_name, value: ->(ios_app) {!ios_app.get_company.nil? ? ios_app.get_company.name : ''}
  end

  define_type AndroidApp do
    field :name, value: ->(android_app) {!android_app.newest_android_app_snapshot.nil? ? android_app.newest_android_app_snapshot.name : ''}
    field :seller_url, value: ->(android_app) {!android_app.newest_android_app_snapshot.nil? ? android_app.newest_android_app_snapshot.seller_url : ''}
    field :seller, value: ->(android_app) {!android_app.newest_android_app_snapshot.nil? ? android_app.newest_android_app_snapshot.seller : ''}
    field :ratings_all, value: ->(android_app) {!android_app.newest_android_app_snapshot.nil? ? android_app.newest_android_app_snapshot.ratings_all_count : 0}
    field :company_name, value: ->(android_app) {!android_app.get_company.nil? ? android_app.get_company.name : ''}
  end

end
