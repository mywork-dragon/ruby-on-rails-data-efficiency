module IosClassification
  
  def perform(snap_id)
    begin
      snapshot = IpaSnapshot.find(snap_id)
      snapshot.scan_status = :scanning
      snapshot.save

      sdks = classify(snap_id)

      snapshot.scan_status = :scanned
      snapshot.save

      # invalidate bad scans
      invalidate_bad_scans(snapshot)

      # sdks
      puts "finished classify"
    rescue => e
      IosClassificationException.create!({
        ipa_snapshot_id: snap_id,
        error: e.message,
        backtrace: e.backtrace
      })

      snapshot = IpaSnapshot.find(snap_id)
      snapshot.scan_status = :failed
      snapshot.save

      raise e
    end
  end

  def invalidate_bad_scans(snapshot)
    # Invalidate ones affected by https://github.com/MightySignal/varys/issues/401
    # Within window of bug, set all the scanned ones to ignored
    IpaSnapshot.where(ios_app_id: snapshot.ios_app_id, scan_status: IpaSnapshot.scan_statuses[:scanned]).where('created_at < ?', DateTime.strptime('Fri Jan 29 14:32:49 2016 -0800', '%a %b %d %H:%M:%S %Y %z')).where('created_at > ?', DateTime.strptime('Thu Jan 7 09:55:33 2016 -0800', '%a %b %d %H:%M:%S %Y %z')).update_all(scan_status: IpaSnapshot.scan_statuses[:arch_issue])
  end

  def bundle_prefixes
    %w(com co net org edu io ui gov cn jp me forward pay common de se oauth main java pl nl rx uk eu fr)
  end

  def is_new_classdump?(snap_id, classdump)
    if Rails.env.production?
      classdump.app_content.present? 
    else
      `find /$HOME/decrypted_ios_apps/ -maxdepth 1 -name '#{snap_id}.json.txt'`.chomp.present?
    end
  end

  def convert_to_summary(ipa_snapshot_id:,classdump:)

    summary_defaults = {
      'binary' => {
        'classdump' => '',
        'strings' => ''
      },
      'files' => [],
      'frameworks' => []
    }

    summary = {}

    if Rails.env.production?

      raise "Empty classdump" unless classdump.class_dump.present?

      url = classdump.class_dump.url
      contents = open(url).read.scrub

    else
      filename = `echo $HOME`.chomp + "/decrypted_ios_apps/#{ipa_snapshot_id}"
      ext = if is_new_classdump?(ipa_snapshot_id, classdump)
        '.json.txt'
      else
        classdump.method == 'classdump' ? ".classdump.txt" : ".txt"
      end
      filename = filename + ext

      contents = File.open(filename) {|f| f.read}.chomp.scrub
    end

    if is_new_classdump?(ipa_snapshot_id, classdump)

      contents = JSON.load(contents)

      type = contents['binary']['type']

      if type == nil
        summary['binary'] = contents['binary']
      elsif type == 'classdump' || type == 'strings'
        summary['binary'] = {}
        summary['binary']['classdump'] = type == 'classdump' ? contents['binary']['contents'] : summary_defaults['binary']['classdump']
        summary['binary']['strings'] = type == 'strings' ? contents['binary']['contents'] : summary_defaults['binary']['strings']
      else
        raise "Unrecognized type"
      end

      summary['frameworks'] = contents['frameworks'] || summary_defaults['frameworks']
      summary['files'] = contents['files'] || summary_defaults['files']
    else
      if classdump.method == 'classdump'
        summary['binary'] = {
          'classdump' => contents,
          'strings' => summary_defaults['binary']['strings']
        }
      elsif classdump.method == 'strings'
        summary['binary'] = {
          'classdump' => summary_defaults['binary']['classdump'],
          'strings' => contents
        }
      else
        raise "Unrecognized classdump method"
      end

      summary['frameworks'] = fw_folders_from_strings(contents)
      summary['files'] = summary_defaults['files']
    end

    summary
  end

  def classify(snap_id)
    ActiveRecord::Base.logger.level = 1

    classdump = ClassDump.where(ipa_snapshot_id: snap_id, dump_success: true).last

    raise "No successful classdumps available" if classdump.nil?

    summary = convert_to_summary(ipa_snapshot_id: snap_id, classdump: classdump)

    classify_all_sources(ipa_snapshot_id: snap_id, classdump: classdump, summary: summary)
  end

  def classify_all_sources(ipa_snapshot_id:, classdump:, summary:)

    classdump_sdks = classify_classdump(summary['binary']['classdump'])
    frameworks_sdks = sdks_from_frameworks(summary['frameworks'])
    files_sdks = sdks_from_files(summary['files'])
    strings_regex_sdks = sdks_from_string_regex(summary['binary']['strings'])

    # These go last because they have side effects (ex. autogenerate sdks)
    js_tag_sdks = sdks_from_js_tags(ipa_snapshot_id, summary['files'])
    dll_sdks = sdks_from_dlls(ipa_snapshot_id, summary['files'])
    strings_sdks = classify_strings(ipa_snapshot_id, summary['binary']['strings'])

    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: classdump_sdks, method: :classdump)
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: strings_sdks, method: :strings)
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: frameworks_sdks, method: :frameworks)
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: files_sdks, method: :file_regex)
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: js_tag_sdks, method: :js_tag_regex)
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: dll_sdks, method: :dll_regex)
    attribute_sdks_to_snap(snap_id: ipa_snapshot_id, sdks: strings_regex_sdks, method: :string_regex)
  end

  def attribute_sdks_to_snap(snap_id:, sdks:, method:)
    sdks.each do |sdk|
      begin
        IosSdksIpaSnapshot.create!(ipa_snapshot_id: snap_id, ios_sdk_id: sdk.id, method: method)
      rescue => e
        nil
      end
    end
  end

  def classify_classdump(contents)

    sdks = sdks_from_classdump(contents: contents)
    puts "Finished classdump"
    sdks
  end

  # Entry point to integrate with @osman
  def classify_strings(snap_id, contents)

    sdks = sdks_from_strings(contents: contents, ipa_snapshot_id: snap_id)
    puts "Finished strings"
    sdks
  end

  def sdks_from_files(files)

    sdks = []

    combined = files.join("\n")
    regexes = SdkFileRegex.where.not(ios_sdk_id: nil)

    regexes.each do |regex_row|
      if regex_row.regex.match(combined)
        sdks << IosSdk.find(regex_row.ios_sdk_id)
      end
    end

    puts "Finished files"
    sdks.uniq
  end

  def sdks_from_dlls(ipa_snapshot_id, files)

    sdks = []

    dlls = files.map do |path|
      match = path.match(/\/([^\/]+\.dll\z)/)
      match[1] if match
    end.compact.uniq

    dlls.each do |dll|
      dll_row = SdkDll.find_or_create_by(name: dll)

      begin
        IpaSnapshotsSdkDll.create!(ipa_snapshot_id: ipa_snapshot_id, sdk_dll_id: dll_row.id)
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end

    regexes = DllRegex.where.not(ios_sdk_id: nil)
    combined = dlls.join("\n")

    regexes.each do |regex_row|
      if regex_row.regex.match(combined)
        sdks << IosSdk.find(regex_row.ios_sdk_id)
      end
    end

    puts "Finished dlls"
    sdks.uniq
  end

  def sdks_from_js_tags(ipa_snapshot_id, files)

    sdks = []

    tags = files.map do |path|
      match = path.match(/\/([^\/]+\.js\z)/)
      match[1] if match
    end.compact.uniq

    # create the tags and entries in join table
    tags.each do |tag|
      tag_row = SdkJsTag.find_or_create_by(name: tag)

      begin
        IpaSnapshotsSdkJsTag.create!(ipa_snapshot_id: ipa_snapshot_id, sdk_js_tag_id: tag_row.id)
      rescue ActiveRecord::RecordNotUnique
        nil
      end
    end

    # match tags against regexes
    regexes = JsTagRegex.where.not(ios_sdk_id: nil)
    combined = tags.join("\n")

    regexes.each do |regex_row|
      if regex_row.regex.match(combined)
        sdks << IosSdk.find(regex_row.ios_sdk_id)
      end
    end

    puts "Finished js tags"
    sdks.uniq
  end

  def sdks_from_string_regex(contents)
    sdks = []

    regexes = SdkStringRegex.where.not(ios_sdk_id: nil)

    regexes.each do |regex_row|
      if contents.scan(regex_row.regex).count > regex_row.min_matches
        sdks << IosSdk.find(regex_row.ios_sdk_id)
      end
    end

    puts "Finished string regex"
    sdks.uniq
  end

  # Get classes from strings
  def classes_from_strings(contents)
    # more generic version, grabs any "string"
    contents.scan(/@"<?([_\p{Alnum}]+)/).flatten.uniq

    # more specific, focuses on classnames and delegates
    # contents.scan(/T@"<?([_\p{Alnum}]+)>?"(?:,.)*_?\p{Alpha}*/).flatten.uniq.compact
  end

  # Get classes from classdump
  def classes_from_classdump(contents)
    contents.scan(/@interface (.*?) :/m).map{ |k,v| k }.uniq
  end

  # Get bundles from strings
  def bundles_from_strings(contents)
    contents.scan(/^(?:#{bundle_prefixes.join('|')})\..*/).map do |package|
      package[0..174] # convert to 175 characters for MYSQL reasons
    end
  end

  # do this for now...eventually delete the old stuff
  def sdks_from_frameworks(frameworks)
    sdks = find_from_fw_folders(fw_folders: frameworks)
    puts "Finished js tags"
    sdks
  end

  # Get FW folders from strings
  def fw_folders_from_strings(contents)
    contents.scan(/^Folder:(.+)\n/).flatten.uniq
  end

  def sdks_from_classdump(contents: contents, search_classes: true, search_fw_folders: false)

    sdks = []

    if search_classes
      classes = classes_from_classdump(contents)
      sdks += sdks_from_classnames(classes: classes)
    end

    if search_fw_folders
      fw_folders = fw_folders_from_strings(contents)
      sdks += find_from_fw_folders(fw_folders: fw_folders)
    end

    sdks = sdks.compact.uniq {|sdk| sdk.id}

  end

  def sdks_from_strings(contents:, ipa_snapshot_id:, search_classes: false, search_bundles: true, search_fw_folders: false)

    sdks = []

    if search_bundles
      bundles = bundles_from_strings(contents)
      sdks += SdkService.find_from_packages(packages: bundles, platform: :ios, snapshot_id: ipa_snapshot_id, read_only: false) # TODO: remove read only flag after regexes are linked and such
    end

    if search_classes
      classes = classes_from_strings(contents)
      sdks += sdks_from_classnames(classes: classes)
    end

    if search_fw_folders
      fw_folders = fw_folders_from_strings(contents)
      sdks += find_from_fw_folders(fw_folders: fw_folders)
    end

    sdks = sdks.compact.uniq {|sdk| sdk.id}
  end

  def sdks_from_classnames(classes:, remove_apple: true)

    classes -= AppleDoc.where(name: classes).pluck(:name) if remove_apple

    collisions = {}
    uniques = []

    # match classnames against regexes
    regexes = HeaderRegex.where.not(ios_sdk_id: nil)
    combined = classes.join("\n")

    regexes.each do |regex_row|
      if regex_row.regex.match(combined)
        uniques << IosSdk.find(regex_row.ios_sdk_id)
      end
    end

    classes.each do |name|
      found = direct_search(name) || source_search(name)
      next if found.nil?
      if found.length == 1
        uniques << found.first
      else
        collisions[name] = found
      end
    end

    # get rid of collisions between the same set of sdks
    # sort ids so ordering doesn't matter
    to_resolve = collisions.values.uniq {|sdks| sdks.map{|x| x.id}.sort}

    # get rid of collisions that include sdks we've already found to exist via uniqueness
    to_resolve.select! do |sdks|
      sdks.find {|sdk| uniques.include?(sdk)}.nil?
    end

    resolved_sdks = []

    to_resolve.each do |sdks|
      sdk = resolve_collision(sdks: sdks)
      resolved_sdks << sdk if !sdk.nil?
    end

    (uniques + resolved_sdks).uniq

  end

  def resolve_collision(sdks:, downloads_threshold: 0.75)
    # check if all map to the same source group
    group_ids = sdks.map {|sdk| sdk.ios_sdk_source_group_id}
    if group_ids.uniq.length == 1 && !group_ids.first.nil?
      group = IosSdkSourceGroup.find(group_ids.first)
      return IosSdk.find(group.ios_sdk_id)
    end

    # check the metrics to see if there's an overwhelming favorite
    # aggregate by group
    downloads = sdks.map {|sdk| get_downloads_for_sdk(sdk)}
    total = downloads.reduce(0) {|x, y| x + y}

    metrics_map = {}
    sdks.each_with_index do |sdk, index|
      if group_ids[index].nil?
        metrics_map[sdk] = downloads[index]
      else
        # put group in table if doesn't exist, otherwise add to total
        group = IosSdkSourceGroup.find(group_ids[index])
        metrics_map[group] = (metrics_map[group] || 0) + downloads[index]
      end
    end

    highest = metrics_map.values.max

    if highest > downloads_threshold * total
      match = metrics_map.key(highest)
      if match.class == IosSdkSourceGroup
        IosSdk.find(match.ios_sdk_id)
      else # match.class == IosSdk
        match
      end
    else
      nil # could not resolve
    end
  end

  def source_search(name)

    ios_sdks = []

    c = CocoapodSourceData.where(name: name)
    ios_sdks += c.map do |csd|
      pod = csd.cocoapod
      if !pod.nil?
        pod.ios_sdk
      end
    end.compact.uniq

    s = IosSdk.joins(:ios_sdk_source_datas).where('ios_sdk_source_data.name' => name).where.not('ios_sdk_source_data.ios_sdk_id' => nil)
    ios_sdks += s

    ios_sdks if !ios_sdks.first.nil? # don't return empty arrays
  end

  def direct_search(q)
    s = %w(sdk -ios-sdk -ios -sdk).map{|p| q+p } << q
    c = IosSdk.find_by_name(s)
    [c] if c.present?
  end

  # debug -- jlew
  def find_from_fw_folders(fw_folders:)
    sdks = []
    fw_folders.each do |fw_folder|
      regex = convert_folder_to_regex(fw_folder)
      match = IosSdk.where('name REGEXP ?', regex).first
      sdks << match if match
    end
    
    sdks
  end

  # convert a folder name to a regex string (for running against sdk names)
  def convert_folder_to_regex(folder_name)
    regex = folder_name.chomp.split('').map do |char|
      if /[^\p{Alnum}]/.match(char)
        '[^a-zA-Z0-9]?' # mysql doesn't have Alnum...I think
      else
        char
      end
    end.join('')

    # require entire match
    "^#{regex}$"
  end

  # Entry point forC
  def sdks_from_strings_file(filename)
    contents = File.open(filename) { |f| f.read }.chomp
    sdks_from_strings_googled(contents: contents, search_classes: false, search_bundles: true, search_fw_folders: true)
  end

  # For testing, entry point to classify string
  # @author Jason Lew
  def search_bundles_from_file(filename)
    contents = File.open(filename) { |f| f.read }.chomp

    bundles = contents.scan(/^(?:#{bundle_prefixes.join('|')})\.(.*)/).flatten.uniq

    search_bundles(bundles, nil)
  end

  # Create entry in join table for every one that it finds
  def search_bundles(bundles, snap_id)
    SdkService.find_from_packages(packages: bundles, platform: :ios)
  end

  def get_downloads_for_sdk(sdk)
    most_recent = sdk.cocoapod_metrics.select {|metrics| metrics.success}.sort_by {|x| x.updated_at}.last
    res = most_recent ? most_recent.stats_download_total || 0 : 0
  end
end