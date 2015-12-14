class TestService

	class << self

		def android_check_exist(id, job_id = nil)
	    # id = params['appId']
	    aa = AndroidApp.find(id)
	  	data = data_hash(aa, job_id, scannable(aa))
	    # render json: data

	  end

	  def start_job_android(id)
	  	id = params['appId']
	  	aa = AndroidApp.find(id)
	  	job_id = ApkSnapshotJob.create!(notes: "SINGLE: #{aa.app_identifier}").id
	  	batch = Sidekiq::Batch.new
			bid = batch.bid
			batch.jobs do
			  ApkSnapshotServiceSingleWorker.perform_async(job_id, bid, aa.id)
			end
			bid
	  end

	  def check_status(id)
	  	# id = params['appId']
	  	aa = AndroidApp.find(id)
	  	# ss = ApkSnapshot.find_by_apk_snapshot_job_id(job_id)
	  	ss = aa.newest_apk_snapshot
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



	  	# e = %w(failure no_response forbidden could_not_connect timeout deadlock not_found)
	  	# o = %w(taken_down bad_device out_of_country bad_carrier)
	  	e = %w(failure no_response forbidden could_not_connect timeout deadlock)
	  	o = %w(taken_down bad_device out_of_country)
	  	if e.any?{|x| ss.send(x+'?') }
	  		0
	  	else
	  		a = o.index(o.select{|x| ss.send(x+'?') }.first)
	  		a.present? && a + 1
	  	end
	  end

	  def scannable(aa)
	  	s = aa.newest_android_app_snapshot
	    e = s.price.to_i.zero? ? nil : 6
	    e = aa.normal? ? nil : AndroidApp.display_types[aa.display_type] if e.nil?
	    e
	  end

	  def data_hash(aa, job_id, error_code)
	    h = Hash.new
	    if error_code.nil?
		    h[:installed] = features aa.installed_sdks
	    	h[:uninstalled] = features aa.uninstalled_sdks
		  end
		  # h[:updated] = aa.apk_snapshots.where(status:1).last && aa.apk_snapshots.where(status:1).last.updated_at
		  j = ApkSnapshotJob.find_by_id(job_id)
		  h[:updated] = j && j.created_at
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

	end

end

# unless the error code is nil, don't do anything

# actual updated date
# download
# scan
# correct error codes

# account for when there is an error code 4, but there is also data




# statuses
#   0 => queueing
#   1 => downloading
#   2 => scanning
#   3 => successful scan
#   4 => failed
# new errors
# 	0 => error connecting with google
# 	1 => taken down
# 	2 => device problem
# 	3 => country problem
# 	4 => carrier problem



# errors
# 	0 => "failure"
# 	1 => "success"
# 	2 => "no response"
# 	3 => "forbidden"
# 	4 => "taken down"
# 	5 => "could not connect"
# 	6 => "timeout"
# 	7 => "deadlock"
# 	8 => "bad device"
# 	9 => "out of country"
# 	10 => "bad carrier"
# 	11 => "not found"