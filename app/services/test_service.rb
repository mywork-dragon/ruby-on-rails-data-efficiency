class TestService

	class << self

		def android_sdks_exist(id)
	    # id = params['appId']
	    aa = AndroidApp.find(id)
	    data = data_hash(aa, scannable(aa))
	    # render json: data
	  end

	  def android_start_scan(id)
	    # id = params['appId']
	    aa = AndroidApp.find(id)
	    job_id = ApkSnapshotJob.create!(notes: "SINGLE: #{aa.app_identifier}").id
	    batch = Sidekiq::Batch.new
	    bid = batch.bid
	    batch.jobs do
	      ApkSnapshotServiceSingleWorker.perform_async(job_id, bid, aa.id)
	    end
	    job_id
	  end

	  def android_scan_status(job_id)
	    # job_id = params['jobId']
	    ss = ApkSnapshot.find_by_apk_snapshot_job_id(job_id)
	    status, error, msg = snap_status(ss)
	    e = {:status => status, :error => error, :message => msg}
	    # render json: e
	  end

	  def snap_status(ss)
	    [0,nil]
	    if ss.present?
	      [1,nil]
	      if ss.status.present?
	        if ss.success? 
	          ss.scan_success? ? [3,nil] : [2,nil]
	        else
	          [4,snap_error(ss)]
	        end
	      end
	    end
	  end

	  def snap_error(ss)
	    e = %w(failure no_response forbidden could_not_connect timeout deadlock not_found)
	    o = %w(taken_down bad_device out_of_country bad_carrier)
	    if e.any?{|x| ss.send(x+'?') }
	      0
	    else
	      a = o.index(o.select{|x| ss.send(x+'?') }.first)
	      a.present? && a + 1
	    end
	  end

	  def scannable(aa)
	    s = aa.newest_android_app_snapshot
	    e = s.price.to_i.zero? ? nil : 5
	    e = aa.normal? ? nil : AndroidApp.display_types[aa.display_type] - 1 if e.nil?
	    e
	  end

	  def data_hash(aa, error_code)
	    h = Hash.new
	    if error_code.nil? || error_code == 6
	      h[:installed] = features aa.installed_sdks
	      h[:uninstalled] = features aa.uninstalled_sdks
	    end
	    h[:updated] = aa.apk_snapshots.where(status:1).last && aa.apk_snapshots.where(status:1).last.last_updated
	    h[:error_code] = error_code || 0
	    h.to_json
	  end

	  def features(h)
	    return nil if h.nil?
	    f = h.map do |x|
	      { :id => x.id,
	        :name => x.name,
	        :website => x.website,
	        :favicon => x.get_favicon,
	        :first_seen => x.first_seen,
	        :last_seen => x.last_seen,
	        :app_count => x.get_current_apps.count,
	        :open_source => x.open_source }
	    end
	    f.sort_by{|x| [x[:open_source] ? 1:0 , -x[:app_count]] }
	  end

	  # def reproduce(n = 100)
	  # 	Rails.application.eager_load!
	  # 	a = ActiveRecord::Base.descendants.map{|x| x.split(' ').first }
	  # 	a.each do |model|
	  # 		columns = model
	  # 	end
	  # end

	end

end

# unless the error code is nil, don't do anything

# actual updated date
# download
# scan
# correct error codes

# account for when there is an error code 4, but there is also data
