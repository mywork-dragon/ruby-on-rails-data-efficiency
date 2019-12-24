module MobileApp

  def self.included base
    base.send :include, InstanceMethods
    base.extend ClassMethods
  end

  module InstanceMethods

    def platform
      self.class.platform
    end

    def ios?
      platform == 'ios'
    end

    def android?
      platform == 'android'
    end

    def mightysignal_public_page_link
      if platform == 'android'
        store = 'google-play'
      else
        store = 'ios'
      end
      "https://mightysignal.com/a/#{store}/#{app_identifier}/#{name.parameterize}"
    end

    def ad_attribution_sdks
      sdk_ids = installed_sdks.map{ |sdk| sdk['id'] }
      tag = Tag.find_by(name: 'Ad Attribution')
      tag.send("#{platform}_sdks").where(id: sdk_ids)
    end

    def tag_as_major_app
      major_tag = Tag.find_by(name: "Major App")
      TagRelationship.find_or_create_by(tag_id: major_tag.id, taggable_id: self.id, taggable_type: self.class.name)
      self.activities.update_all(major_app: true)
    end

    def untag_as_major_app
      major_tag = Tag.find_by(name: "Major App")
      tag = TagRelationship.find_by(tag_id: major_tag.id, taggable_id: self.id, taggable_type: self.class.name)
      tag.destroy
      self.activities.update_all(major_app: false) unless is_major_app?
    end

    def is_major_app?
      is_in_top_200? || fortune_rank || major_publisher? || major_app_tag?
    end

    def major_app_tag?
      self.tags.any? { |tag| tag.name == "Major App" }
    end

    def run_length_encode_app_snapshot_fields(snap_table, fields)
      fields.append(:created_at)
      snapshots = snap_table.pluck(*fields)
      run_length_encode_app_snapshot_fields_from_fetched(snapshots, fields)
    end

    # This from_fetched hook is used by the AndroidApp.bulk_export method in order to allow
    # for optimizing the query for historical snapshots.
    def run_length_encode_app_snapshot_fields_from_fetched(snapshots, fields)
      rts = snapshots.reject{|x| x[-1].nil?}.group_by {|x| x.first(x.size - 1) }.values

      output = []
      rts.map do |bin|
        bin = bin.select {|x| x[-1]}
        min = bin.map{|x| x[-1]}.min
        max = bin.map{|x| x[-1]}.max
        record = {'start_date' => min, 'stop_date' => max}
        (0..fields.size-2).map {|i| record[fields[i]] = bin[0][i]}
        output.append(record)
      end
      output = output.sort_by {|x| x['stop_date']}
      if output.length > 0
        output[-1]['stop_date'] = nil
      end
      output
    end

    def sdk_history
      # TEMPLATE
      resp = {
        installed_sdks: [],
        uninstalled_sdks: [],
        updated: nil
      }

      snap = ios? ? newest_ipa_snapshot : newest_apk_snapshot
      return resp if snap.nil?

      snapshots = if ios?
                      ipa_snapshots.includes(:ios_sdks)
                        .where(scan_status: IpaSnapshot.scan_statuses[:scanned])
                        .order(:good_as_of_date).to_a
                    else
                      apk_snapshots.includes(:android_sdks)
                        .where(scan_status: ApkSnapshot.scan_statuses['scan_success'])
                        .order(:good_as_of_date).to_a
                    end


      # REFACTOR: Misused `and` keyword
      if android? && newest_android_app_snapshot.try(:version) == "Varies with device"
        snapshots = filter_older_versions_from_android_apk_snapshots(snapshots)
      end
      return resp if snapshots.empty?

      previous_sdk_info = {}
      previous_sdks = []
      sdk_info = nil
      snapshots.each_with_index do |snapshot, i|
        sdk_info = previous_sdk_info.dup
        sdks = if ios?
                 snapshot.ios_sdks.where('ios_sdks.flagged = false').distinct.to_a
               else
                 snapshot.android_sdks.where('android_sdks.flagged = false').distinct.to_a
               end

        sdks.each do |sdk|
          # never seen before (first install)
          if previous_sdk_info[sdk.id].nil?
            sdk_info[sdk.id] = {
              'id' => sdk.id,
              'name' => sdk.name,
              'website' => sdk.website,
              'favicon' => ios? ? sdk.favicon : sdk.get_favicon,
              'activities' => [
                {
                  'type' => :install,
                  'date' => snapshot.first_valid_date
                }
              ],
              'first_seen_date' => snapshot.first_valid_date,
              'last_seen_date' => snapshot.good_as_of_date
            }
            # seen before but missing from directly previous (re-install)
          elsif !previous_sdks.include?(sdk)
            sdk_info[sdk.id]['last_seen_date'] = snapshot.good_as_of_date
            sdk_info[sdk.id].delete('first_unseen_date')
            sdk_info[sdk.id]['activities'] << {
              'type' => :install,
              'date' => snapshot.first_valid_date
            }
          else # nothing changed w.r.t this sdk
            sdk_info[sdk.id]['last_seen_date'] = snapshot.good_as_of_date
          end
        end

        (previous_sdks - sdks).each do |sdk|
          # in previous but missing from current (uninstall)
          sdk_info[sdk.id]['first_unseen_date'] = snapshot.first_valid_date
          sdk_info[sdk.id]['activities'] << {
            'type' => :uninstall,
            'date' => snapshot.first_valid_date
          }
        end


        previous_sdks = sdks
        previous_sdk_info = sdk_info
      end

      previous_sdk_ids = previous_sdks.map(&:id)
      sdk_info.each do |id, info|
        if previous_sdk_ids.include?(id)
          resp[:installed_sdks] << info
        else
          resp[:uninstalled_sdks] << info
        end
      end
      resp[:updated] = snapshots.last.good_as_of_date
      resp.with_indifferent_access
    end

    def tagged_sdk_history(only_show_tagged=false)
      tagged_data = { installed_sdks: [], uninstalled_sdks: [],
                           installed_sdks_count: 0, uninstalled_sdks_count: 0 }
      untagged_name = 'Others'
      history = sdk_history

      [:installed_sdks, :uninstalled_sdks].each do |type|
        sdks = history[type]
        sdks.each do |sdk|
          sdk_model = ios? ? IosSdk.find(sdk['id']) : AndroidSdk.find(sdk['id'])

          tag = sdk_model.tags.first
          tag_name = tag.try(:name) || untagged_name

          next if tag_name == untagged_name && only_show_tagged

          existing = tagged_data[type].find { |x| x[:name] == tag_name }
          if existing
            existing[:sdks] << sdk
          else
            tagged_data[type] << {
              id: tag.try(:id),
              name: tag_name,
              sdks: [sdk]
            }
          end

          tagged_data["#{type}_count".to_sym] += 1
        end
        tagged_data[type] = tagged_data[type].sort_by { |x| x[:name] }
      end

      tagged_data[:updated] = history[:updated]
      tagged_data
    end
  end

  module ClassMethods

    def ad_attribution_sdk_ids
      tag = Tag.where(id: 24).first
      return [] unless tag

      return tag.send("#{platform}_sdks").pluck(:id)
    end

    def rankings_table
      "#{platform}_app_rankings".to_sym
    end

    def newest_ranking_snapshot
      "#{platform}_app_ranking_snapshot".classify.constantize.last_valid_snapshot
    end

    def app_ranking_id_field
      "#{platform}_app_ranking_snapshot_id".to_sym
    end

    def top_n_app_ids(n)
      self.joins(rankings_table).
        where(rankings_table =>
          {app_ranking_id_field => newest_ranking_snapshot.id}).
        where('rank < ?', n + 1).select(:rank, "#{self.table_name}.*").
        order('rank ASC').pluck(:id)
    end

    def top_n_apps(n)
      top_n_app_ids(n).map {|id| self.find(id)}
    end

  end

end
