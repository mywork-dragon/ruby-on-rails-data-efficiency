class TestService

	class << self

		def parse_ios

			class_dump = File.open('../Zinio.classdump.txt').read

			clss = class_dump.scan(/@protocol (.*?)\n/m)

			clss.each do |cls|

				str = cls.first[/[^<]+/]

				puts str unless %w(ns ui categories table tab scroll search page library button zoom issue index image server theme purchase cl zinio).any?{ |s| str.downcase.include?(s) }
				
			end

		end










		def android_sdks_exist(android_app_id = 1)

		    # android_app_id = params['appId']

		    updated = nil

		    companies = nil

		    aa = AndroidApp.find(android_app_id)

		    if aa.newest_apk_snapshot.blank?

		      error_code = 1

		    else

		      new_snap = aa.newest_apk_snapshot

		      if new_snap.status == "success"

		        updated = new_snap.updated_at

		        companies = new_snap.android_sdk_companies

		        current_ids = companies.map(&:id)

		        total_ids = []

		        aa.apk_snapshots.joins(:android_sdk_companies).each do |cos|

		          cos_ids = cos.android_sdk_companies.map(&:id)

		          total_ids = total_ids + cos_ids

		        end

		        removed_companies = AndroidSdkCompany.where(id: (total_ids.uniq - current_ids))

		        error_code = companies.count.zero? ? 1:0

		      else

		        error_code = 5

		      end
		 
		    end

		    # render json: sdk_hash(companies, removed_companies, updated, error_code)

		    puts sdk_hash(companies, removed_companies, updated, error_code)

		  end

		  def scan_android_sdks

		    android_app_id = params['appId']

		    updated = companies = nil

		    aa = AndroidApp.find(android_app_id)

		    price = aa.newest_android_app_snapshot.price.to_i

		    if aa.taken_down

		      error_code = 2

		    elsif !price.zero?

		      error_code = 4

		    else

		      app_identifier = aa.app_identifier

		      begin
		        download_apk(android_app_id, app_identifier)
		      rescue
		        nil
		      end

		      new_snap = AndroidApp.find(android_app_id).newest_apk_snapshot

		      if new_snap.present? && new_snap.status == "success"

		        begin
		          scan_apk(aa.id)
		        rescue
		          nil
		        end

		        companies = new_snap.android_sdk_companies

		        updated = new_snap.updated_at

		        error_code = 0

		      else
		        error_code = 3
		      end

		    end

		    render json: sdk_hash(companies, updated, error_code)

		  end

		  def sdk_hash(companies, removed_companies, last_updated, error_code)

		    main_hash = Hash.new

		    installed_co_hash, installed_os_hash = form_hash(companies)

		    uninstalled_co_hash, uninstalled_os_hash = form_hash(removed_companies)

		    error_code = 1 if installed_co_hash.empty? && installed_os_hash.empty? && uninstalled_co_hash.empty? && uninstalled_os_hash.empty? && error_code.zero?
		    
		    main_hash['installed_sdk_companies'] = installed_co_hash

		    main_hash['installed_open_source_sdks'] = installed_os_hash

		    main_hash['uninstalled_sdk_companies'] = uninstalled_co_hash

		    main_hash['uninstalled_open_source_sdks'] = uninstalled_os_hash

		    main_hash['last_updated'] = last_updated

		    main_hash['error_code'] = error_code

		    main_hash.to_json

		  end

		  def form_hash(companies)

		    co_hash = Hash.new

		    os_hash = Hash.new

		    if companies.present?

		      companies.each do |company|

		        next if company.nil? || company.flagged

		        main_company = company.parent_company_id.present? ? AndroidSdkCompany.find(company.parent_company_id) : company

		        children = if company.parent_company_id.present?

		          cc = company

		          { 'name' => cc.name, 'website' => cc.website, 'favicon' => cc.favicon.nil? && cc.open_source ? 'https://assets-cdn.github.com/pinned-octocat.svg' : cc.favicon }

		        else

		          nil

		        end

		        if company.open_source

		          if company.parent_company_id.blank?

		            os_hash[main_company.name] = { 'website' => main_company.website, 'favicon' => main_company.favicon, 'android_app_count' => main_company.android_apps.count, 'children' => [children].compact }

		          else

		            co_hash[main_company.name]['children'] << children

		          end

		        else

		          if co_hash[main_company.name].blank? || company.parent_company_id.blank?

		            co_hash[main_company.name] = { 'website' => main_company.website, 'favicon' => main_company.favicon, 'android_app_count' => main_company.android_apps.count, 'children' => [children].compact }

		          else

		            co_hash[main_company.name]['children'] << children

		          end

		        end

		      end

		    end

		    co_hash = sort_hash(co_hash)

		    os_hash = sort_hash(os_hash)

		    return co_hash, os_hash

		  end

		  def sort_hash(hash)
		    hash = hash.sort_by{ |k,v| -v['android_app_count'] }.to_h
		  end



	end

end