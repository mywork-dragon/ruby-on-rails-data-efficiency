class SdkCompanyServiceWorker

	include Sidekiq::Worker

	sidekiq_options backtrace: true, :retry => false, queue: :sdk

	def perform(app_id)

    get_and_save_favicon(app_id)

  end

  def transition_from_sdk_companies_to_android_sdk_companies(company_id)

    sdk_com = SdkCompany.find(company_id)

    if (sdk_com.website.present? || sdk_com.alias_website.present?) && !sdk_com.flagged?

      website = httpify( sdk_com.alias_website.present? ? sdk_com.alias_website : sdk_com.website )
      
      name = sdk_com.alias_name.present? ? sdk_com.alias_name : sdk_com.name

      asc = AndroidSdkCompany.create_with(website: website, favicon: sdk_com.favicon).find_or_create_by(name: name)

      AndroidSdkPackagePrefix.create_with(android_sdk_company: asc).find_or_create_by(prefix: sdk_com.name)

    end

    nil

  end


  def name_from_package(package_name)

    @api_words = %w(key secret token app)

    package = strip_prefix(package_name)

    return nil if package.blank?

    package = package.capitalize if package == package.upcase && package.count('.').zero?

    name = camel_split(package.split('.').first)

    return nil if name.nil?

    name

  end


  def create_company_from_name(name)

    # aa = ApkSnapshot.find(apk_snapshot_id).android_app

    url = google_search(name)

    github_url, company_name = github_google_search(name) if url.blank?

    github = github_url.present?

    website = [url, github_url].compact.first

    if website.present?

      parent_company = AndroidSdkPackagePrefix.find_by_prefix(company_name)

      parent_company_id = parent_company.present? ? parent_company.android_sdk_company_id : nil 

      asc = AndroidSdkCompany.create_with(website: website, parent_company_id: parent_company_id, open_source: github).find_or_create_by(name: name)

      #delete this later
      # AndroidSdkPackagePrefix.find_or_create_by(prefix: name)

      aspp = AndroidSdkPackagePrefix.find_by_prefix(name)

      aspp.android_sdk_company_id = asc.id

      aspp.save

      # AndroidSdkCompaniesAndroidApp.find_or_create_by(android_sdk_company: asc, android_app: aa)

      if asc.favicon.nil? && !github

        favicon_url = get_favicon(website)

        asc.favicon = favicon_url

        asc.save

      end

      return asc.id

    else

      return nil

    end

  end

  def name_check?(name)

    name.count('0-9') < 4 && name.exclude?('android') && name.downcase.gsub(/[^a-z0-9\s]/i, '').present? && name.length >= 3 && name.split(' ').select{|s| s.length == 1 }.count < 1

  end

  def httpify(url)
    url = %w(http https).any?{|h| url.include? h} ? url : "http://#{url}"
  end


  # def remove_dots(company_id)

  #   sdk_com = SdkCompany.find(company_id)

  #   if sdk_com.website.present?
  #     company = sdk_com.website.chomp('/').gsub('://','')

  #     if company.split('.com').first.include?('/')

  #       sdk_com.website = nil
  #       sdk_com.save

  #     end

  #   end

  # end

  # def delete_duplicates(company_id)

  #   sdk_com = SdkCompany.find(company_id)

  #   sdk_com.delete if sdk_com.sdk_packages.count.zero?

  # end

  def find_company(app_id)

    @api_words = %w(key secret token app)

    ap = AndroidApp.find_by_id(app_id).newest_apk_snapshot.android_packages

    company_ids = []

    ap.select{|a| a unless " #{a.package_name}".include?(' android.') || a.package_name.blank? }.map{|b| b.package_name}.each do |package|

      company_id = find_or_create_company_from_package(app_id, package)

      next if company_id.nil?

      sdk_package = SdkPackage.create_with(sdk_company_id: company_id).find_or_create_by(package_name: package)

      company_ids << company_id

    end

    company_ids

  end

  def find_or_create_company_from_package(app_id, package)

    known_strings = %w(MobileAppTracking HasOffers)

    package = strip_prefix(package)

    if package.count('.').zero?

      package = package.capitalize if package == package.upcase

      contains_known_string = known_strings.select{|w| package.include? w }

      if contains_known_string.present?

        name = contains_known_string.first

      else

        name = camel_split_key_words(package.split(/(?=[A-Z_])/).first)

      end

      return nil if name.split(' ').select{|s| s.length == 1 }.count > 1

      if is_word?(name, app_id)

        if @api_words.any?{|i| package.downcase.include? i}

          sdk_com = SdkCompany.find_or_create_by(name: name)

        else

          sdk_com = SdkCompany.find_by_name(name)

        end

      end

    else

      name = package.split('.').first

      if is_word?(name, app_id)

        contains_known_string = known_strings.select{|w| name.include? w }

        if contains_known_string.present?

          name = contains_known_string.first

        else
          name = camel_split(name)
        end

        return nil if name.split(' ').select{|s| s.length == 1 }.count > 1

        sdk_com =  SdkCompany.find_or_create_by(name: name)

      end

    end

    sdk_id = sdk_com.id unless sdk_com.blank?

    sdk_com_check = SdkCompany.where(name: name)

    if sdk_com_check.count > 1
      sdk_id = sdk_com_check.map{|s| s.id}.min 
    end

    return sdk_id unless sdk_id.blank?

    nil

  end

  def strip_prefix(package)

    clean_package = package.gsub('co.','').gsub('main.','')

    pre = clean_package.split('.').first

    package_arr = clean_package.split('.')

    package_arr.shift if %w(com co net org edu io ui gov cn jp me forward pay common de se oauth main java pl nl rx uk).include?(pre) || pre.blank?

    package = package_arr.join('.')

  end

  def camel_split(words)
    if (words =~ /[A-Z]{2}/).nil? && words != words.upcase
      words.split(/(?=[A-Z])/).map(&:capitalize).join(' ').strip
    else
      words
    end
  end

  def camel_split_key_words(words)

    name = words.split(/(?=[A-Z])/).map do |w| 
      if @api_words.any?{|k| w.downcase.include? k }
        nil
      else
        w.capitalize
      end
    end

    name.compact.join(' ').strip

  end

  def is_word?(w, app_id)

    if app_id.nil?
      return true if w.count('0-9') < 4 && w.exclude?('android') && w.downcase.gsub(/[^a-z0-9\s]/i, '').present? && w.length >= 3
    else
      ap = AndroidApp.find(app_id).app_identifier
      package = strip_prefix(ap).split('.').first
      return true if w.count('0-9') < 4 && w.exclude?('android') && w.downcase.gsub(/[^a-z0-9\s]/i, '').present? && w.length >= 3 && package.similar(w) <= 75
    end

    false

  end


  def google_company(sdk_company_id)

    return nil if delete_if_duplicate(sdk_company_id)

    sdk_com = SdkCompany.find_by_id(sdk_company_id)

    if sdk_com.website.blank? && sdk_com.alias_website.blank?

      query = sdk_com.name

      url = google_search(query)

      if url.present? && url != '0'

        company = url.chomp('/').gsub('://','')

        if company.split('.com').first.exclude?('/')

            sdk_com.website = url

            sdk_com.favicon = get_favicon(url) if sdk_com.favicon.nil?

        end

        # sdk_com.website = url

        # sdk_com.favicon = get_favicon(url) if sdk_com.favicon.nil?

      else
        sdk_com.website = nil
      end

      sdk_com.save

    end

    if sdk_com.alias_website.present? && sdk_com.favicon.blank?
      sdk_com.favicon = get_favicon(sdk_com.alias_website)
      sdk_com.save
    end

  end


  def google_search(query)

    q = query + " sdk"

    result = res(type: :get, req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q})

    return nil if result.nil?

    results_html = Nokogiri::HTML(result.body)

    i = 0

    results = results_html.search('cite').each do |cite|
      url = cite.inner_text

      ext = %w(.com .co .net .org .edu .io .ui .gov .cn .jp .me .ly).select{|s| s if url.include?(s) }.first

      next if ext.nil?

      %w(www. doc. docs. dev. developer. developers. cloud. support. help. documentation. dashboard. sdk. wiki.).each{|p| url = url.gsub(p,'') }

      domain = url.split(ext).first.to_s + ext.to_s

      i += 1

      break if i > 3

      return httpify(domain) if domain.include?(query.downcase) && domain.exclude?('...') && domain != '0' && domain.count('-').zero?

    end

    nil

  end


  def github_google_search(query)

    q = query + " github"

    result = res(type: :get, req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q})

    return nil if result.nil?

    results_html = Nokogiri::HTML(result.body)

    results = results_html.search('cite').each do |cite|
      url = cite.inner_text

      if url.include?('github.io/')
        repo_name = url.gsub('https://','').split('/')[1]

        clean_query = query.downcase.gsub(' ','')
        clean_repo_name = repo_name.downcase
        
        if clean_repo_name == clean_query && url.exclude?('...')
          company_name = url.gsub('http://','').gsub('https://','').gsub('www.','').split('.').first.capitalize
          return httpify(url), company_name
        end
      end

    end


    results = results_html.search('cite').each do |cite|
      url = cite.inner_text

      if url.include?('github.com/')
        repo_name = url.gsub('https://','').split('/')[2]

        return nil if repo_name.nil?

        clean_query = query.downcase.gsub(' ','')
        clean_repo_name = repo_name.downcase

        if clean_repo_name == clean_query && url.exclude?('...')
          company_name = url.gsub('https://','').split('/')[1].capitalize
          return httpify(url), company_name
        end
      end

    end

    nil

  end

  def get_favicon(url)

    return nil if url.include?('github.com/') || url.nil?

    begin
      favicon = WWW::Favicon.new
      favicon_url = favicon.find(url)
    rescue
      nil
    end
  end

  def get_and_save_favicon(app_id)

    asc = AndroidSdkCompany.find(app_id)

    url = asc.website

    return nil if url.include?('github.com/')

    begin
      favicon = WWW::Favicon.new
      favicon_url = favicon.find(url)

      asc.favicon = favicon_url

      asc.save

    rescue
      nil
    end
  end

  def delete_if_duplicate(company_id)
    sdk_com = SdkCompany.find(company_id).sdk_packages
    if sdk_com.count.zero?
      sdk_com.delete
      return true
    end
    false
  end

  def res(req:, params:, type:)

    if Rails.env.production?

      begin

        mp = MicroProxy.transaction do

          p = MicroProxy.lock.order(last_used: :asc).first
          p.last_used = DateTime.now
          p.save

          p

        end

        proxy = "#{mp.private_ip}:8888"

        response = CurbFu.send(type, req, params) do |curb|
          curb.proxy_url = proxy
          curb.ssl_verify_peer = false
          curb.max_redirects = 3
          curb.timeout = 5
        end

      rescue

        nil

      end

    else

      response = CurbFu.send(type, req, params) do |curb|
        curb.ssl_verify_peer = false
        curb.max_redirects = 3
        curb.timeout = 5
      end

    end

  end

end