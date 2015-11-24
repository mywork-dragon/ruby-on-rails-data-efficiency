class IosClassificationServiceWorker

  include Sidekiq::Worker

  sidekiq_options backtrace: true, queue: :ios_live_scan

  def perform(snap_id)
    snapshot = IpaSnapshot.find(snap_id)
    snapshot.scan_status = :scanning
    snapshot.save

    sdks = classify(snap_id)

    snapshot.scan_status = :scanned
    snapshot.save

    sdks
  end

  def bundle_prefixes
    %w(com co net org edu io ui gov cn jp me forward pay common de se oauth main java pl nl rx uk eu fr)
  end

  def classify(snap_id)
    ActiveRecord::Base.logger.level = 1

    classdump = ClassDump.where(ipa_snapshot_id: snap_id, dump_success: true).last

    return if classdump.nil?

    if Rails.env.production?

      url = classdump.class_dump.url
      contents = open(url).read.scrub
    elsif Rails.env.development?

      ios_app = IpaSnapshot.find(snap_id).ios_app

      filename = `echo $HOME`.chomp + "/decrypted_ios_apps/#{ios_app.app_identifier}"
      ext = classdump.method == 'classdump' ? ".classdump.txt" : ".txt"
      filename = filename + ext

      contents = File.open(filename) {|f| f.read}.chomp.scrub
    end

    if classdump.method == 'classdump'
      classify_classdump(snap_id, contents)
    else classdump.method == 'strings'
      classify_strings(snap_id, contents)
    end
  end

  def attribute_sdks_to_snap(snap_id:, sdks:)
    sdks.each do |sdk|
      begin
        IosSdksIpaSnapshot.create!(ipa_snapshot_id: snap_id, ios_sdk_id: sdk.id)
      rescue => e
        nil
      end
    end
  end

  def classify_classdump(snap_id, contents)

    puts "Classifying classdump".red

    sdks = sdks_from_classdump(contents: contents)
    attribute_sdks_to_snap(snap_id: snap_id, sdks: sdks)
    sdks
  end

  # Entry point to integrate with @osman
  def classify_strings(snap_id, contents)
    puts "Classifying strings".blue
    sdks = sdks_from_strings(contents: contents, ipa_snapshot_id: snap_id)
    # TODO: uncomment
    attribute_sdks_to_snap(snap_id: snap_id, sdks: sdks)
    sdks
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
    contents.scan(/^(?:#{bundle_prefixes.join('|')})\..*/)
  end

  # Get FW folders from strings
  def fw_folders_from_strings(contents)
    contents.scan(/^Folder:(.+)\n/).flatten.uniq
  end

  def sdks_from_classdump(contents: contents, search_classes: true, search_fw_folders: true)
    puts "Classifying classdump".blue

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

  def sdks_from_strings(contents:, ipa_snapshot_id:, search_classes: false, search_bundles: true, search_fw_folders: true)

    sdks = []

    if search_bundles
      bundles = bundles_from_strings(contents)
      sdks += SdkService.find_from_packages(packages: bundles, platform: :ios, snapshot_id: ipa_snapshot_id, read_only: false) # TODO: remove read only flag after regexes are linked and such
      puts "SDKs via bundles"
      ap sdks
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

    if remove_apple
      classes -= AppleDoc.select(:name).where(name: classes).map {|row| row.name}
    end

    collisions = {}
    uniques = []

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

    puts "Uniques".blue
    ap uniques

    puts "Resolved Collisions".yellow
    ap resolved_sdks

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
    c = CocoapodSourceData.where(name: name)
    ios_sdks = c.map do |csd|
      pod = csd.cocoapod
      if !pod.nil?
        pod.ios_sdk
      end
    end.compact.uniq

    ios_sdks if !ios_sdks.first.nil? # don't return empty arrays
  end

  def direct_search(q)
    s = %w(sdk -ios-sdk -ios -sdk).map{|p| q+p } << q
    c = IosSdk.find_by_name(s)
    [c] if c.present?
  end

  def find_from_fw_folders(fw_folders: fw_folders)
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
    ap bundles

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