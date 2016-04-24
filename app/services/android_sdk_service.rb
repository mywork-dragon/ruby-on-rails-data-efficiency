module AndroidSdkService

  class LiveScan

    class << self

      # Starts the Live Scan
      # @return the job_id
      def start_scan(android_app_id)
        aa = AndroidApp.find(android_app_id)
        job_id = ApkSnapshotJob.create!(notes: "SINGLE: #{aa.app_identifier}", job_type: :one_off).id
        batch = Sidekiq::Batch.new
        bid = batch.bid
        batch.jobs do
          ApkSnapshotServiceSingleWorker.perform_async(job_id, bid, aa.id)
        end
        job_id
      end

      # 0: Preparing
      # 1: Downloading
      # 2: Scanning
      # 3: Complete
      # 4: Failed
      # 5: Unchanged version
      # @return :status and :error in a Hash
      def check_status(job_id: job_id)
        ss = ApkSnapshot.where(apk_snapshot_job_id: job_id).last
        if ss.present?
          if ss.status.present?
            if ss.success? 

              if ss.scan_success?
                return {status: 3, error: nil}
              elsif ss.scan_failure?
                return {status: 4, error: snap_error(ss)}
              elsif ss.unchanged_version?
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
        o_h = {
          'taken_down' => 1,
          'bad_device' => 2, 
          'out_of_country' => 3, 
          'bad_carrier' => 4,
          'unchanged_version' => 5
        }
        o = %w(taken_down bad_device out_of_country bad_carrier)
        if e.any?{ |x| ss.send(x + '?') }  # if any error from e
          return 0 # (error connecting with Google) 
        else
          o_h.each do |status, code|
            if ss.send(status + '?')
              return code
            end
          end
          return nil
        end
      end

    end

  end

  class App

    class << self

      def get_sdk_response(android_app_id, apk_snapshot_id: nil)
        aa = AndroidApp.find(android_app_id)
        data = sdk_response_h(aa, apk_snapshot_id: apk_snapshot_id)
      end

      # Gets the error code
      #
      # ERROR CODES AND STATUSES FOR ANDROID_CHECK_STATUS
      # statuses
      #   0 => queueing
      #   1 => downloading
      #   2 => scanning
      #   3 => successful scan
      #   4 => failed
      def error_code(aa)
        ss = aa.newest_android_app_snapshot

        return 5 unless ss.price.to_i.zero? # paid is code 5

        display_type_to_error_code(aa.display_type)
      end

      # Maps the display type to the error code
      def display_type_to_error_code(display_type)
        display_type = display_type.to_sym
        mapping = {
          normal: nil,
          taken_down: 0, 
          foreign: 1, 
          device_incompatible: 2, 
          carrier_incompatible: 3,
          item_not_found: 4, 
        }
        mapping[display_type]
      end

      # Helper for get_sdk_response
      def sdk_response_h(aa, apk_snapshot_id: nil)
        h = {}
        ec = error_code(aa)

        return h unless ec.nil?

        snap = apk_snapshot_id.nil? ? aa.newest_successful_apk_snapshot : ApkSnapshot.find(apk_snapshot_id)
        
        return h if snap.nil?

        installed_sdks = snap.android_sdks

        first_snaps_with_current_sdks = ApkSnapshot.joins(:android_sdks_apk_snapshots).select('min(first_valid_date) as first_seen', :version, :android_app_id, 'android_sdk_id').where(id: aa.apk_snapshots.scan_success, 'android_sdks_apk_snapshots.android_sdk_id' => installed_sdks.pluck(:id)).group('android_sdk_id')
        last_snaps_without_current_sdks = ApkSnapshot.joins(:android_sdks_apk_snapshots).select('max(good_as_of_date) as last_seen', 'version', 'android_sdk_id').where(id: aa.apk_snapshots.scan_success).where.not('android_sdks_apk_snapshots.android_sdk_id' => installed_sdks.pluck(:id)).group('android_sdk_id')

        uninstalled_sdks = AndroidSdk.where(id: last_snaps_without_current_sdks.pluck(:android_sdk_id))

        installed_display_sdk_to_snap = AndroidSdk.joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').select('android_sdks.id as k, IFNULL(android_sdk_links.dest_sdk_id, android_sdks.id) as v').where(id: installed_sdks).reduce({}) do |memo, map_row|

          key = map_row['v']

          current_snapshot = first_snaps_with_current_sdks.find { |snapshot| snapshot.android_sdk_id == map_row['k'] }

          if memo[key].nil? || current_snapshot.first_seen < memo[key].first_seen
            memo[key] = current_snapshot
          end

          memo
        end

        puts "installed_display_sdk_to_snap: #{installed_display_sdk_to_snap}"  #debug

        uninstalled_display_sdk_to_snap = AndroidSdk.joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').select('android_sdks.id as k, IFNULL(android_sdk_links.dest_sdk_id, android_sdks.id) as v').where(id: uninstalled_sdks).reduce({}) do |memo, map_row|

          key = map_row['v']
          current_snapshot = last_snaps_without_current_sdks.find {|snapshot| snapshot.android_sdk_id == map_row['k']}

          if memo[key].nil? || current_snapshot.last_seen > memo[key].last_seen
            memo[key] = current_snapshot
          end

          memo
        end

        installed_display_sdks = AndroidSdk.where(id: AndroidSdk.select('IFNULL(android_sdk_links.dest_sdk_id, android_sdks.id)').joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').where(id: installed_sdks))
        uninstalled_display_sdks = AndroidSdk.where(id: AndroidSdk.select('IFNULL(android_sdk_links.dest_sdk_id, android_sdks.id)').joins('LEFT JOIN android_sdk_links ON android_sdk_links.source_sdk_id = android_sdks.id').where(id: uninstalled_sdks))

        partioned_installed_sdks = partition_sdks(android_sdks: installed_display_sdks)
        partioned_uninstalled_sdks = partition_sdks(android_sdks: uninstalled_display_sdks)

        # format the responses
        h[:installed] = partioned_installed_sdks.map do |sdk|
          formatted = format_sdk(sdk)
          apk_snap = installed_display_sdk_to_snap[sdk.id]
          formatted['first_seen_date'] = apk_snap ? apk_snap.first_seen : nil
          formatted
        end.uniq

        h[:uninstalled] = partioned_uninstalled_sdks.map do |sdk|
          next unless installed_display_sdk_to_snap[sdk.id].nil?
          formatted = format_sdk(sdk)
          apk_snap = uninstalled_display_sdk_to_snap[sdk.id]
          formatted['last_seen_date'] = apk_snap ? apk_snap.last_seen : nil
          formatted
        end.compact.uniq
        # h[:uninstalled] = {}  # show no uninstalls for now  -- TEMP
        h[:updated] = snap.good_as_of_date
        h[:error_code] = ec || nil
        h
      end

      def partition_sdks(android_sdks:)
        partitions = android_sdks.reduce({os: [], non_os: []}) do |memo, sdk|
          if sdk.present? && (!sdk.flagged || sdk.flagged == 0) 
            if FaviconHelper.has_os_favicon?(sdk.favicon) && !memo[:os].include?(sdk)
              memo[:os].push(sdk)
            elsif !memo[:non_os].include?(sdk)
              memo[:non_os].push(sdk)
            end
          end

          memo
        end

        %i(os non_os).each do |property|
          # use sort_by because it's an expensive operation and it's more efficient than sort for this type
          partitions[property] = partitions[property].sort_by do |sdk|
            sdk.name.downcase
          end
        end

        (partitions[:non_os] + partitions[:os]).uniq
      end

      def format_sdk(android_sdk)
        {
          'id' => android_sdk.id,
          'name' => android_sdk.name,
          'website' => android_sdk.website,
          'favicon' => android_sdk.get_favicon,
          'open_source' => android_sdk.open_source
        }
      end

    end

  end

end