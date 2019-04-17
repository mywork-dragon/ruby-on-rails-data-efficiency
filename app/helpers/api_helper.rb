module ApiHelper
  def app_stores
    AppStore.enabled.order("display_priority IS NULL, display_priority ASC")
  end

  def set_file_headers(file_name:"mightysignal_apps.csv")
    headers["Content-Type"] = "text/csv"
    headers["Content-disposition"] = "attachment; filename=\"#{file_name}\""
  end

  def csv_header
    headers = ['MightySignal App ID', 'App Store/Google Play ID', 'App Name', 'App Type', 'Mobile Priority', 'Release Date', 'Last Updated', 'FB Ad Spend', 'First Seen FB Ads', 'Last Seen FB Ads',
               'In App Purchases', 'Categories', 'MightySignal Publisher ID', 'Publisher Name', 'App Store/Google Play Publisher ID',
               'Fortune Rank', 'Publisher Domain(s)', 'MightySignal App Page', 'MightySignal Publisher Page', 'Ratings', 'Downloads', 'Street Numbers', 'Street Names',
               'Cities', 'States', 'Countries', 'Postal Codes']
    AppStore.enabled.order("display_priority IS NULL, display_priority ASC").each do |store|
      headers << "User Base - #{store.country_code}"
    end
    headers
  end

  def get_contacts_to_export(domains, quality)
    results = ClearbitContact.joins(:domain_datum).where(
      'domain_data.domain IN (?) AND quality > (?)', 
      domains.uniq, 
      quality).pluck(
        :id, :title, :full_name, :given_name, :family_name, :email, :linkedin
      )
  end

  def render_csv(filter_args: nil, apps: nil, additional_fields:[], &block)
    set_file_headers
    set_streaming_headers

    response.status = 200

    self.response_body = csv_lines(filter_args: filter_args, apps: apps, additional_fields: additional_fields, &block)
  end

  def csv_lines(filter_args: nil, apps: nil, additional_fields:[], &block)
    header_fields = csv_header + additional_fields
    Enumerator.new do |y|
      y << header_fields.to_csv

      if filter_args
        filter_args[:page_size] = 1000
        filter_args[:page_num] = 1
        filter_args[:order_by] ||= 'asc'
        filter_args[:sort_by] ||= 'name'
        platform = filter_args.delete(:platform)

        filter_results = nil
        results = []

        while filter_results.nil? || (filter_args[:page_num] <= 20 && filter_results.count > 0)
          if platform == 'ios'
            filter_results = FilterService.filter_ios_apps(filter_args)
            results = FilterService.order_helper(filter_results, filter_args[:sort_by], filter_args[:order_by])
          else
            filter_results = FilterService.filter_android_apps(filter_args)
            results = FilterService.order_helper(filter_results, filter_args[:sort_by], filter_args[:order_by])
          end

          if results.any?
            add_apps_to_enum(results: results, enum: y, header_fields: header_fields, &block)
            filter_args[:page_num] += 1
          end
        end
      else
        add_apps_to_enum(results: apps, enum: y, header_fields: header_fields, &block)
      end
    end
  end

  def set_streaming_headers
    headers['X-Accel-Buffering'] = 'no'

    headers["Cache-Control"] ||= "no-cache"
    headers.delete("Content-Length")
  end

  def es_ios_app_to_csv(es_app)
    es_app = es_app.attributes
    headquarters = es_app['headquarters'].first
    user_bases = es_app['user_bases']
    row = [
      es_app['id'],
      es_app['app_identifier'],
      es_app['name'],
      'IosApp',
      es_app['mobile_priority'],
      es_app['released'],
      es_app['last_updated'],
      es_app['facebook_ads'],
      es_app['first_seen_ads'],
      es_app['last_seen_ads'],
      es_app['in_app_purchases'],
      es_app['categories'].try(:join, ', '),
      es_app['publisher_id'],
      es_app['publisher_name'],
      es_app['publisher_identifier'],
      es_app['fortune_rank'],
      DomainLinker.new.publisher_to_domains('ios', es_app['publisher_id']).try(:first, 10).try(:join, ', '),
      'http://www.mightysignal.com/app/app#/app/ios/' + es_app['id'].to_s,
      es_app['publisher_id'].present? ? "http://www.mightysignal.com/app/app#/publisher/ios/#{es_app['publisher_id']}" : nil,
      es_app['ratings_all'],
      nil,
      headquarters.try(:[], 'street_number'),
      headquarters.try(:[], 'street_name'),
      headquarters.try(:[], 'city'),
      headquarters.try(:[], 'state'),
      headquarters.try(:[], 'country'),
      headquarters.try(:[], 'postal_code'),
    ]
    if user_bases
      app_stores.each do |store|
        row << user_bases.select{|user_base| user_base['country_code'] == store.country_code}.first.try(:[], 'user_base')
      end
    else
      app_stores.each do |store|
        row << ""
      end
    end
    row
  end

  def es_android_app_to_csv(es_app)
    es_app = es_app.attributes
    headquarters = es_app['headquarters'].first
    row = [
      es_app['id'],
      es_app['app_identifier'],
      es_app['name'],
      'AndroidApp',
      es_app['mobile_priority'],
      nil,
      es_app['last_updated'],
      es_app['facebook_ads'],
      es_app['first_seen_ads'],
      es_app['last_seen_ads'],
      es_app['in_app_purchases'],
      es_app['categories'].try(:join, ', '),
      es_app['publisher_id'],
      es_app['publisher_name'],
      es_app['publisher_identifier'],
      es_app['fortune_rank'],
      DomainLinker.new.publisher_to_domains('android', es_app['publisher_id']).try(:first, 10).try(:join, ', '),
      'http://www.mightysignal.com/app/app#/app/android/' + es_app['id'].to_s,
      es_app['publisher_id'].present? ? "http://www.mightysignal.com/app/app#/publisher/android/#{es_app['publisher_id']}" : nil,
      es_app['ratings_all'],
      "#{ActionController::Base.helpers.number_to_human(es_app['downloads_min'])}-#{ActionController::Base.helpers.number_to_human(es_app['downloads_max'])}",
      headquarters.try(:[], 'street_number'),
      headquarters.try(:[], 'street_name'),
      headquarters.try(:[], 'city'),
      headquarters.try(:[], 'state'),
      headquarters.try(:[], 'country'),
      headquarters.try(:[], 'postal_code'),
    ]
    app_stores.each do |store|
      row << (store.country_code == 'US' ? es_app['user_base'] : nil)
    end
    row
  end

  def add_apps_to_enum(results:, enum:, header_fields:, &block)
    results.each do |app|
      app_csv = if ['IosApp', 'AndroidApp'].include?(app.class.name)
        app.to_csv_row
      else
        app.class.name == 'AppsIndex::IosApp' ? es_ios_app_to_csv(app) : es_android_app_to_csv(app)
      end
      if block
        app_csv = yield header_fields, app_csv
      end
      enum << app_csv.to_csv
    end
  end



end
