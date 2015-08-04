class SdkCompanyServiceWorker

	include Sidekiq::Worker

	sidekiq_options backtrace: true, :retry => false, queue: :sdk
  
	def perform(app_id)
    clean(app_id)
  end

  def find_company(app_id)

    ap = AndroidApp.find_by_id(app_id).newest_apk_snapshot.android_packages

    ap.select{|a| a unless " #{a.package_name}".include?(' android.') || a.package_name.blank? }.map{|b| b.package_name}.each do |package|

      company_id = find_or_create_company_from_package(package)

      next if company_id.nil?

      sdk_package = SdkPackage.create_with(sdk_company_id: company_id).find_or_create_by(package_name: package)

    end

  end

  def find_or_create_company_from_package(package)

    pre = package.split('.').first

    package_arr = package.split('.')

    ext = 'com'

    if %w(com net org edu eu io ui gov).include?(pre) || pre.blank?
      package_arr.shift
      ext = pre
    end

    package = package_arr.join('.')

    if package.count('.').zero?

      package = package.capitalize if package == package.upcase

      name = camel_split(package.split(/(?=[A-Z_])/).first)

      if is_word? name

        if package.downcase.include?('key') || package.downcase.include?('secret') || package.downcase.include?('token') || package.downcase.include?('app')

          website = name.downcase.gsub(' ','') + "." + ext

          sdk_com = SdkCompany.create_with(website: website).find_or_create_by(name: name)

        else

          sdk_com = SdkCompany.find_by_name(name)

        end

      end

    else

      name = package.split('.').first

      if is_word? name

        name = camel_split(name)

        website = name.downcase.gsub(' ','') + "." + ext

        sdk_com =  SdkCompany.create_with(website: website).find_or_create_by(name: name)

      end

    end

    return sdk_com.id unless sdk_com.blank?

    nil

  end

  def camel_split(words)

    words.split(/(?=[A-Z])/).map(&:capitalize).join(' ')

  end

  def is_word?(w)
    return true if w.count('0-9').zero? && w.exclude?('android') && w.downcase.gsub(/[^a-z0-9\s]/i, '').present? && w.length >= 3
    false
  end


  def google_company(sdk_company_id)

    sdk_com = SdkCompany.find_by_id(sdk_company_id)

    query = sdk_com.name

    link = google_search(query)

    if link.present? && link != 0
      sdk_com.website = link
    else
      sdk_com.website = nil
    end

    sdk_com.save

  end


  def google_search(query)

    q = query + " sdk"

    results_html = Nokogiri::HTML(res(type: :get, req: {:host => "www.google.com/search", :protocol => "https"}, params: {'q' => q}).body)

    results = results_html.search('cite').each do |cite|
      url = cite.inner_text

      ext = %w(.com .co .net .org .edu .io .ui .gov).select{|s| s if url.include?(s) }.first

      next if ext.nil?

      %w(www. doc. docs. dev. developer. developers. cloud. support. help. documentation.).each{|p| url = url.gsub(p,'') }

      domain = url.split(ext).first.to_s + ext.to_s

      return domain if domain.include? query.downcase

    end

    results

  end

  def res(req:, params:, type:)

    if Rails.env.production?

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

    else

      response = CurbFu.send(type, req, params) do |curb|
        curb.ssl_verify_peer = false
        curb.max_redirects = 3
        curb.timeout = 5
      end

    end

  end

  def clean(sdk_company_id)
    sdk_com = SdkCompany.find(sdk_company_id)

    url = sdk_com.website

    if url == 0
      sdk_com.website = nil
      sdk_com.save
    else

      %w(www. doc. docs. dev. developer. developers. cloud. support. help. documentation.).each{|p| url = url.gsub(p,'') }

      sdk_com.website = url
      sdk_com.save

    end
  end

end