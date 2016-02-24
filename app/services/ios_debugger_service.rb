class IosDebuggerService

  class IpaSnapshotOverview

    include IosClassification

    def initialize(ipa_snapshot_id)
      @ipa_snapshot_id = ipa_snapshot_id
    end

    def summary
      return @summary if @summary
      build_summary
      @summary
    end

    def get_info

      ipa_snapshot = IpaSnapshot.find(@ipa_snapshot_id)

      {
        ipa_snapshot_id: ipa_snapshot.id,
        success: ipa_snapshot.success,
        scan_status: ipa_snapshot.scan_status,
        version: ipa_snapshot.version,
        first_valid_date: ipa_snapshot.first_valid_date,
        valid_date: ipa_snapshot.good_as_of_date,
        created: ipa_snapshot.created_at
      }

    end

    def build_summary
      summary = {}

      ipa_snapshot = IpaSnapshot.find(@ipa_snapshot_id)

      summary[:meta] = get_info

      classdump = ClassDump.where(ipa_snapshot_id: @ipa_snapshot_id, dump_success: true).last

      if classdump.nil?
        summary[:message] = 'No classdumps available'
      else

        summary[:meta][:summary_url] = classdump.class_dump.url
        snap_summary = convert_to_summary(ipa_snapshot_id: @ipa_snapshot_id, classdump: classdump)

        summary[:frameworks] = snap_summary['frameworks']
        summary[:files] = snap_summary['files']
        summary[:headers] = classes_from_classdump(snap_summary['binary']['classdump'])
        summary[:packages] = bundles_from_strings(snap_summary['binary']['strings'])

        summary[:sdks] = IosSdk.joins(:ios_sdks_ipa_snapshots).select(:name, :method).where('ios_sdks_ipa_snapshots.ipa_snapshot_id = ?', @ipa_snapshot_id).map do |row|

          method = IosSdksIpaSnapshot.methods.keys[row[:method]] if row[:method]
          {
            sdk: row.name,
            method: method
          }
        end.sort_by {|entry| entry[:sdk]}

      end

      @summary = summary
    end
  end

  def initialize(ios_app_id:)
    @ios_app_id = ios_app_id
    raise "App #{ios_app_id} does not exist" if IosApp.find_by_id(ios_app_id).nil?
  end

  # View metadata on all the apps snapshots
  def snapshots
    IpaSnapshot.where(ios_app_id: @ios_app_id).map do |ipa_snapshot|
      IpaSnapshotOverview.new(ipa_snapshot.id).get_info
    end
  end

  # View more detailed information about one specific snapshot. Give it the ipa snapshot id (you can use snapshots to find all your options)
  def view(ipa_snapshot_id)
    ipa_snapshot = IpaSnapshot.find_by_id(ipa_snapshot_id)

    raise "No snapshot with id #{ipa_snapshot_id}" if ipa_snapshot.nil?

    IpaSnapshotOverview.new(ipa_snapshot_id)
  end

  # Convenience method to get the detailed information on the most recent successful snapshot
  def last
    ipa_snapshot = IosApp.find(@ios_app_id).get_last_ipa_snapshot(scan_success: true)

    return "App has not been successfully scanned" if ipa_snapshot.nil?

    IpaSnapshotOverview.new(ipa_snapshot.id)
  end
end