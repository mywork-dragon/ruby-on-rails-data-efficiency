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
        byebug
        nil
      end
    end
  end

  def classify_classdump(snap_id, contents)

    puts "Classifying classdump".red

    sdks = sdks_from_classdump(contents: contents)
    # TODO: uncomment
    byebug
    attribute_sdks_to_snap(snap_id: snap_id, sdks: sdks)
    byebug
    sdks
  end

  # Entry point to integrate with @osman
  def classify_strings(snap_id, contents)
    puts "Classifying strings".blue
    sdks = sdks_from_strings(contents: contents)
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
      sdks += find_from_classes(classes: classes)
    end

    if search_fw_folders
      fw_folders = fw_folders_from_strings(contents)
      sdks += find_from_fw_folders(fw_folders: fw_folders)
    end

    sdks = sdks.compact.uniq {|sdk| sdk.id}

  end

  def sdks_from_strings(contents:, search_classes: false, search_bundles: true, search_fw_folders: true)

    sdks = []

    if search_bundles
      bundles = bundles_from_strings(contents)
      sdks += SdkService.find_from_packages(packages: bundles, platform: :ios, read_only: Rails.env.development?) # TODO: remove read only flag after regexes are linked and such
      puts "SDKs via bundles"
      ap sdks
    end

    if search_classes
      classes = classes_from_strings(contents)
      sdks += find_from_classes(classes: classes, matches_threshold: 1)
    end

    if search_fw_folders
      fw_folders = fw_folders_from_strings(contents)
      sdks += find_from_fw_folders(fw_folders: fw_folders)
    end

    sdks = sdks.compact.uniq {|sdk| sdk.id}
  end

  def find_from_classes(classes:, remove_apple: false, matches_threshold: 0)
    sdks = []

    if remove_apple
      classes -= AppleDoc.select(:name).where(name: classes).map {|row| row.name}
    end

    classes.each do |name|
      found = search(name) || code_search(name)
      # sdks << {term: name, sdk: found} if found
      sdks << found
    end

    sdks.group_by {|x| x}.select {|k, v| v.length > matches_threshold}.keys
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

  def search(q)
    s = %w(sdk -ios-sdk -ios -sdk).map{|p| q+p } << q
    c = IosSdk.find_by_name(s)
    c if c.present?
  end

  def code_search(name)

    c = CocoapodSourceData.where(name: name)
    ios_sdks = c.map do |csd|
      pod = csd.cocoapod
      if !pod.nil?
        pod.ios_sdk
      end
    end.compact.uniq

    puts "found #{ios_sdks.length} matches for #{name}"
    ios_sdks.length <= 1 ? ios_sdks.first : handle_collisions(ios_sdks)
  end

  def get_downloads_for_sdk(sdk)
    most_recent = sdk.cocoapod_metrics.select {|metrics| metrics.success}.sort_by {|x| x.updated_at}.last
    res = most_recent ? most_recent.stats_download_total || 0 : 0
  end

  def handle_collisions(sdks, req = 0.8)

    puts "Collision between #{sdks.map {|x| x.name}.join(',')}"
    # TODO: make this 1 query instead of 
    downloads = sdks.map {|sdk| get_downloads_for_sdk(sdk)}
    total = downloads.reduce(0) {|x, y| x + y}

    highest = downloads.max
    sdks[downloads.find_index(highest)] if highest > req * total

    # TODO: consider hard links
  end

end