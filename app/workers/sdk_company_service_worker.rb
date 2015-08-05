class SdkCompanyServiceWorker

	include Sidekiq::Worker

	sidekiq_options backtrace: true, :retry => false, queue: :sdk

	def perform(app_id)

    find_company(app_id)

  end

  def find_company(app_id)

    @api_words = %w(key secret token app)
    @url_exts = %w(.com .co .net .org .edu .io .ui .gov .cn .jp .me)

    ap = AndroidApp.find_by_id(app_id).newest_apk_snapshot.android_packages

    ap.select{|a| a unless " #{a.package_name}".include?(' android.') || a.package_name.blank? }.map{|b| b.package_name}.each do |package|

      company_id = find_or_create_company_from_package(app_id, package)

      next if company_id.nil?

      sdk_package = SdkPackage.create_with(sdk_company_id: company_id).find_or_create_by(package_name: package)

    end

  end

  def find_or_create_company_from_package(app_id, package)

    pre = package.split('.').first

    package_arr = package.split('.')

    ext = 'com'

    if @url_exts.include?(pre) || pre.blank?
      package_arr.shift
      ext = pre
    end

    package = package_arr.join('.')

    if package.count('.').zero?

      package = package.capitalize if package == package.upcase

      name = camel_split(package.split(/(?=[A-Z_])/).first)

      return nil if name.split(' ').any?{|s| s.length == 1 }

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

        name = camel_split(name)

        sdk_com =  SdkCompany.find_or_create_by(name: name)

      end

    end

    # Check name again

    sdk_id = sdk_com.id unless sdk_com.blank?

    sdk_com_check = SdkCompany.where(name: name)

    if sdk_com_check.count > 1
      sdk_id = sdk_com_check.map{|s| s.id}.min 
    end

    return sdk_id unless sdk_id.blank?

    nil

  end

  def camel_split(words)

    name = words.split(/(?=[A-Z])/).map do |w| 
      if @api_words.any?{|k| w.downcase.include? k }
        nil
      else
        w.capitalize
      end
    end

    name.join(' ').strip

  end

  def is_word?(w, app_id)

    aa = AndroidApp.find(app_id)

    play_id = aa.get_company.google_play_identifier.gsub(/[^a-z0-9\s]/i,'').gsub(' ','').downcase if aa.get_company && aa.get_company.google_play_identifier
    app_name = aa.newest_android_app_snapshot.name.gsub(' ','').downcase if aa.newest_android_app_snapshot && aa.newest_android_app_snapshot.name

    if w.count('0-9').zero? && w.exclude?('android') && w.downcase.gsub(/[^a-z0-9\s]/i, '').present? && w.length >= 3
      if play_id.present? && app_name.present?
        if play_id.similar(w) <= 0.75 && app_name.similar(w) <= 0.75
          return true
        end
      else
        return true
      end
    end
    
    false
  end


  def google_company(sdk_company_id)

    sdk_com = SdkCompany.find_by_id(sdk_company_id)

    query = sdk_com.name

    link = google_search(query)

    if link.present? && link != '0'

      sdk_com.website = link

      sdk_com.favicon = get_favicon(link)

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

      ext = @url_exts.select{|s| s if url.include?(s) }.first

      next if ext.nil?

      %w(www. doc. docs. dev. developer. developers. cloud. support. help. documentation. dashboard. sdk. wiki.).each{|p| url = url.gsub(p,'') }

      domain = url.split(ext).first.to_s + ext.to_s

      return domain if domain.include? query.downcase

    end

    nil

  end

  def get_favicon(url)
    begin
      favicon = WWW::Favicon.new
      favicon_url = favicon.find(url)
    rescue
      nil
    end
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

  # def clean(sdk_company_id)
  #   sdk_com = SdkCompany.find(sdk_company_id)

  #   url = sdk_com.website

  #   if url == 0
  #     sdk_com.website = nil
  #     sdk_com.save
  #   else

  #     %w(www. doc. docs. dev. developer. developers. cloud. support. help. documentation.).each{|p| url = url.gsub(p,'') }

  #     sdk_com.website = url
  #     sdk_com.save

  #   end
  # end

end