class AndroidLiveScanService

  class << self

    # 0: Preparing
    # 1: Downloading
    # 2: Scanning
    # 3: Complete
    # 4: Failed
    # @return A 2-element Array. First element is the status. Second is the error.
    def check_status(job_id: job_id)
      ss = ApkSnapshot.find_by_apk_snapshot_job_id(job_id)
      if ss.present?
        if ss.status.present?
          if ss.success? 

            if ss.scan_success?
              return {status: 3, error: nil}
            elsif ss.scan_failure?
              return {status: 4, error: snap_error(ss)}
            else # nil (still pending)
              return {status: 2, error: nil}
            end
          else
            return {status: 4, error: snap_error(ss)}
          end
        else
          return {status: 1, error: nil}
        end
      else
        return {status: 0, error: nil}
      end
    end

    def snap_error(ss)
      e = %w(failure no_response forbidden could_not_connect timeout deadlock not_found)
      o = %w(taken_down bad_device out_of_country bad_carrier)
      if e.any?{ |x| ss.send(x + '?') }  # if any error from e
        return 0 # (error connecting with Google) 
      else
        a = o.index(o.select{|x| ss.send(x+'?') }.first)  # index of first error from o
        return nil if a.blank?
        return a + 1 # add 1 (because 0 index counts for everything in e)
      end
    end

  end

end