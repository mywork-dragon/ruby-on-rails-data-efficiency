module AndroidSdkService

  class App

    class << self

      def get_sdk_response(android_app_id, force_live_scan_enabled=false, apk_snapshot_id: nil)
        aa = AndroidApp.find(android_app_id)
        data = sdk_response_h(aa, force_live_scan_enabled, apk_snapshot_id: apk_snapshot_id)
      end

      def get_tagged_sdk_response(android_app_id, only_show_tagged=false, force_live_scan_enabled: false)
        new_sdk_response = { installed_sdks: Hash.new {[]}, uninstalled_sdks: Hash.new {[]},
                             installed_sdks_count: 0, uninstalled_sdks_count: 0 }
        untagged_name = 'Others'

        [:installed_sdks, :uninstalled_sdks].each do |type|
          sdks = get_sdk_response(android_app_id)[type]
          sdks.each do |sdk|
            android_sdk = AndroidSdk.find(sdk["id"])
            tag_name = android_sdk.tags.first.try(:name) || untagged_name
            next if tag_name == untagged_name && only_show_tagged
            new_sdk_response[type][tag_name] += [sdk]
          end
        end

        installed_sdks, uninstalled_sdks = [], []
        ((new_sdk_response[:installed_sdks].keys - [untagged_name]).sort + [untagged_name]).each do |key|
          # don't add data for untagged_name unless we have sdks for it
          value = new_sdk_response[:installed_sdks][key]
          if value.present?
            installed_sdks << {name: key, sdks: value}
            new_sdk_response[:installed_sdks_count] += value.count
          end
        end

        ((new_sdk_response[:uninstalled_sdks].keys - [untagged_name]).sort + [untagged_name]).each do |key|
          # don't add data for untagged_name unless we have sdks for it
          value = new_sdk_response[:uninstalled_sdks][key]
          if value.present?
            uninstalled_sdks << {name: key, sdks: value}
            new_sdk_response[:uninstalled_sdks_count] += value.count
          end
        end

        new_sdk_response[:installed_sdks] = installed_sdks
        new_sdk_response[:uninstalled_sdks] = uninstalled_sdks

        get_sdk_response(android_app_id).merge(new_sdk_response)
      end

      # Maps the display type to the error code
      def display_type_to_error_code(display_type)
        display_type = display_type.try(:to_sym)
        mapping = {
          taken_down: 0,
          #foreign: 1,
          paid: 2
        }
        mapping[display_type] if display_type
      end

      # Helper for get_sdk_response
      def sdk_response_h(aa, force_live_scan_enabled=false, apk_snapshot_id: nil)
        h = {
          installed_sdks: [],
          uninstalled_sdks: []
        }

        successful_apk_snapshots = ApkSnapshot.includes(:android_sdks).where(:android_app_id => aa.id, :scan_status => ApkSnapshot.scan_statuses["scan_success"]).to_a
        successful_apk_snapshots.sort_by! {|x| x.good_as_of_date}
        snap = successful_apk_snapshots.last

        h[:live_scan_enabled] = force_live_scan_enabled || ServiceStatus.is_active?(:android_live_scan)
        h[:error_code] = display_type_to_error_code(aa.display_type)

        return h if snap.nil?

        h[:updated] = snap.good_as_of_date

        all_sdks = Set.new(successful_apk_snapshots.flat_map {|x| x.android_sdks})
        installed_sdks = snap.android_sdks
        uninstalled_sdks = all_sdks - Set.new(installed_sdks)

        first_seen = Hash.new {[DateTime.new(3000,1,1), nil]}
        last_seen = Hash.new {[DateTime.new(1970,1,1), nil]}

        last_snapshot_index = successful_apk_snapshots.count - 1

        successful_apk_snapshots.each_with_index.map do |snap, i|
          snap.android_sdks.map do |android_sdk|
            if snap.first_valid_date <= first_seen[android_sdk.id][0]
              first_seen[android_sdk.id] = [snap.first_valid_date, i]
            end
            if snap.good_as_of_date >= last_seen[android_sdk.id][0]
              last_seen[android_sdk.id] = [snap.good_as_of_date, i]
            end
          end
        end


        [[:installed_sdks, installed_sdks], [:uninstalled_sdks, uninstalled_sdks]].map do |partition, sdks|
          partition = h[partition]
          sdks.map do |sdk|
            if (!sdk.flagged || sdk.flagged == 0)
              formatted = format_sdk(sdk)
              formatted['last_seen_date'] = last_seen[sdk.id][0]
              formatted['first_seen_date'] = first_seen[sdk.id][0]

              # If this SDK has been uninstalled set first unseen date
              if last_seen.include?(sdk.id) and last_seen[sdk.id][1] < last_snapshot_index
                next_index = last_seen[sdk.id][1] + 1
                formatted['first_unseen_date'] = successful_apk_snapshots[next_index].first_valid_date
              end
              partition.push(formatted)
            end
          end
        end
       return h
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
