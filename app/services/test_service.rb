class TestService

	class << self

		def scan_android_sdks(android_app_id)

		    # android_app_id = params['appId']

		    updated, companies, removed_companies, error_code = nil

		    aa = AndroidApp.find(android_app_id)

		    price = aa.newest_android_app_snapshot.price.to_i

		    if aa.taken_down

		      error_code = 2

		    elsif !price.zero?

		      error_code = 4

		    else

		      app_identifier = aa.app_identifier

		      # begin
		      #   download_apk(android_app_id, app_identifier)
		      # rescue
		      #   nil
		      # end

		      download_apk(android_app_id, app_identifier)

		      new_snap = aa.newest_apk_snapshot

		      if new_snap.present? && new_snap.status == "success"

		        # begin
		        #   scan_apk(aa.id)
		        # rescue
		        #   ApkSnapshotException.create(name: "Finished scanning: #{e.message}", backtrace: e.backtrace)
		        # end

		        # begin
		        #   companies, removed_companies, updated, error_code = get_sdks(android_app_id: android_app_id)
		        # rescue => e
		        #   ApkSnapshotException.create(name: "Scan Problem: #{e.message}", backtrace: e.backtrace)
		        # end

		        error_code = 1

		      else
		        error_code = 3
		      end

		    end

		    # render json: sdk_hash(companies, removed_companies, updated, error_code)

		    sdk_hash(companies, removed_companies, updated, error_code)

		  end

		  def get_sdks(android_app_id:)

		    updated = nil

		    companies = nil

		    removed_companies = nil

		    aa = AndroidApp.find(android_app_id)

		    if aa.newest_apk_snapshot.blank?

		      error_code = 1

		    else

		      new_snap = aa.newest_apk_snapshot

		      if new_snap.status == "success"

		        updated = new_snap.updated_at

		        companies = new_snap.android_sdk_companies

		        removed_companies = get_removed_companies(android_app: aa, companies: companies)

		        error_code = companies.count.zero? ? 1:0

		      else

		        error_code = 5

		      end
		 
		    end

		    return companies, removed_companies, updated, error_code

		  end

		  def get_removed_companies(android_app:, companies:)

		    current_ids = companies.map(&:id)

		    total_ids = []

		    android_app.apk_snapshots.joins(:android_sdk_companies).each do |cos|

		      cos_ids = cos.android_sdk_companies.map(&:id)

		      total_ids = total_ids + cos_ids

		    end

		    AndroidSdkCompany.where(id: (total_ids.uniq - current_ids))

		  end

		  def sdk_hash(companies:, removed_companies:, updated:, error_code:)

		    main_hash = Hash.new

		    installed_co_hash, installed_os_hash = form_hash(companies)

		    uninstalled_co_hash, uninstalled_os_hash = form_hash(removed_companies)

		    error_code = 1 if installed_co_hash.empty? && installed_os_hash.empty? && uninstalled_co_hash.empty? && uninstalled_os_hash.empty? && error_code.zero?
		    
		    main_hash['installed_sdk_companies'] = installed_co_hash

		    main_hash['installed_open_source_sdks'] = installed_os_hash

		    main_hash['uninstalled_sdk_companies'] = uninstalled_co_hash

		    main_hash['uninstalled_open_source_sdks'] = uninstalled_os_hash

		    main_hash['updated'] = updated

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

		          { 'name' => cc.name, 'website' => cc.website, 'favicon' => (cc.favicon.nil? && cc.open_source) ? 'https://assets-cdn.github.com/pinned-octocat.svg' : cc.favicon }

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

		  def download_apk(android_app_id, app_identifier)

		    job_id = ApkSnapshotJob.create!(notes: "SINGLE: #{app_identifier}").id

		    batch = Sidekiq::Batch.new
		    bid = batch.bid

		    batch.jobs do
		      ApkSnapshotServiceSingleWorker.perform_async(job_id, bid, android_app_id)
		    end

		    sleep 10

		    # 360.times do
		    #   # break if Sidekiq::Batch::Status.new(bid).complete?
		    #   # break if ApkSnapshot.where(apk_snapshot_job_id: job_id).first.status.present?
		    #   # sleep 0.25
		    # end

		  end

		  def scan_apk(android_app_id)

		    batch = Sidekiq::Batch.new
		    bid = batch.bid

		    batch.jobs do
		      PackageSearchServiceWorker.perform_async(android_app_id)
		    end

		    360.times do
		      break if Sidekiq::Batch::Status.new(bid).complete?
		      sleep 0.25
		    end

		  end


	end

end