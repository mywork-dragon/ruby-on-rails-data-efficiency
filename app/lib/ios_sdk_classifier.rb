require_relative 'ios_sdk_classification/ios_header_classifier'
require_relative 'ios_sdk_classification/ios_framework_classifier'

class IosSdkClassifier

  DEFAULT_MAX_WAIT_ATTEMPTS = 30

  class NoClassdumps < RuntimeError; end
  class Unprocessed < RuntimeError; end

  attr_accessor :classdump, :results
  attr_writer :max_waits
  attr_reader :options

  def initialize(ipa_snapshot_id, options={})
    @ipa_snapshot_id = ipa_snapshot_id
    @options = options
  end

  # debug method
  def compare
    classify
    rows = IpaSnapshot.find(@ipa_snapshot_id).ios_sdks_ipa_snapshots
    existing = {}
    rows.each do |row|
      m = row.method.to_sym
      existing[m] = existing[m] || Set.new
      existing[m].add(row.ios_sdk_id)
    end

    current = {}
    @results.keys.each do |key|
      @results[key].each do |ios_sdk|
        current[key] = current[key] || Set.new
        current[key].add(ios_sdk.id)
      end
    end

    diffs = []
    (existing.keys + current.keys).uniq.each {|k| diffs << k unless existing[k] == current[k]}

    if diffs.empty?
      puts 'SUCCESS'
    else
      puts 'FAILURE'
      puts diffs.uniq
    end

    {
      current: current,
      existing: existing
    }
  end

  def max_waits
    @max_waits || DEFAULT_MAX_WAIT_ATTEMPTS
  end

  def log_debug(str)
    puts "#{@ipa_snapshot_id}: #{str}"
  end

  def classify
    load_classdump
    ensure_processed!
    build_results
  end

  def should_classify?(method)
    !(@options[:exclude] && @options[:exclude].include?(method))
  end

  def build_results
    @results = {}
    @results[:classdump] = sdks_from_classes if should_classify?(:classdump)
    @results[:frameworks] = sdks_from_frameworks if should_classify?(:frameworks)
    @results[:file_regex] = sdks_from_files if should_classify?(:file_regex)
    @results[:string_regex] = sdks_from_string_regex if should_classify?(:string_regex)
    @results[:js_tag_regex] = sdks_from_js_tag_regex if should_classify?(:js_tag_regex)
    @results[:dll_regex] = sdks_from_dll_regex if should_classify?(:dll_regex)
    @results[:strings] = sdks_from_strings if should_classify?(:strings)
    @results
  end

  def sdks_from_strings
    packages = @classdump.packages
    SdkService.find_from_packages(
      packages: packages,
      platform: :ios,
      snapshot_id: @ipa_snapshot_id,
      read_only: true
    )
  end

  def sdks_from_dll_regex
    files = @classdump.files
    sdks = []

    dlls = files.map do |path|
      match = path.match(/\/([^\/]+\.dll\z)/)
      match[1] if match
    end.compact.uniq

    regexes = DllRegex.where.not(ios_sdk_id: nil)
    combined = dlls.join("\n")

    regexes.each do |regex_row|
      if regex_row.regex.match(combined)
        sdks << IosSdk.find(regex_row.ios_sdk_id)
      end
    end

    sdks.uniq
  end

  def sdks_from_js_tag_regex
    files = @classdump.files
    sdks = []

    tags = files.map do |path|
      match = path.match(/\/([^\/]+\.js\z)/)
      match[1] if match
    end.compact.uniq

    # match tags against regexes
    regexes = JsTagRegex.where.not(ios_sdk_id: nil)
    combined = tags.join("\n")

    regexes.each do |regex_row|
      if regex_row.regex.match(combined)
        sdks << IosSdk.find(regex_row.ios_sdk_id)
      end
    end

    sdks.uniq
  end

  def sdks_from_string_regex
    text = @classdump.strings
    sdks = []

    regexes = SdkStringRegex.where.not(ios_sdk_id: nil)

    regexes.each do |regex_row|
      if text.scan(regex_row.regex).count > regex_row.min_matches
        sdks << IosSdk.find(regex_row.ios_sdk_id)
      end
    end

    sdks.uniq
  end

  def sdks_from_files
    files = @classdump.files
    sdks = []

    combined = files.join("\n")
    regexes = SdkFileRegex.where.not(ios_sdk_id: nil)

    regexes.each do |regex_row|
      if regex_row.regex.match(combined)
        sdks << IosSdk.find(regex_row.ios_sdk_id)
      end
    end
    sdks.uniq
  end

  def sdks_from_frameworks
    frameworks = @classdump.frameworks
    IosFrameworkClassifier.find_from_frameworks(frameworks)
  end

  # default to using jtool classes...then class-dump classes
  def sdks_from_classes
    classes = jtool_classes || @classdump.classes
    IosHeaderClassifier.sdks_from_classnames(classes: classes)
  end

  # allow for graceful failure of jtool classes for legacy reasons
  def jtool_classes
    @classdump.jtool_classes
  rescue MightyAws::S3::NoSuchKey
    nil
  end

  def load_classdump
    cd = ClassDump.where(ipa_snapshot_id: @ipa_snapshot_id, dump_success: true).last
    raise NoClassdumps unless cd.present?
    @classdump = cd
  end

  def ensure_processed!
    attempt = 0
    while attempt < max_waits
      return if @classdump.processed?
      attempt += 1
      log_debug "Attempt #{attempt} - waiting for processing to complete"
      sleep 1
    end

    raise Unprocessed
  end

  def save!
    @results.keys.each do |method|
      next if @results[method].nil?

      ios_sdk_ids = @results[method].map(&:id)
      existing = IosSdksIpaSnapshot.where(
        ipa_snapshot_id: @ipa_snapshot_id,
        method: IosSdksIpaSnapshot.methods[method] # index is not correct here
      ).pluck(:ios_sdk_id)
      to_add = ios_sdk_ids - existing
      to_remove = existing - ios_sdk_ids
      remove_existing(method, to_remove) if to_remove.count > 0
      add_new(method, to_add) if to_add.count > 0
    end
  end

  def remove_existing(method, ios_sdk_ids)
    IosSdksIpaSnapshot.where(
      ipa_snapshot_id: @ipa_snapshot_id,
      ios_sdk_id: ios_sdk_ids,
      method: IosSdksIpaSnapshot.methods[method]
    ).delete_all
  end

  def add_new(method, ios_sdk_ids)
    rows = ios_sdk_ids.map do |ios_sdk_id|
      IosSdksIpaSnapshot.new(
        ipa_snapshot_id: @ipa_snapshot_id,
        ios_sdk_id: ios_sdk_id,
        method: method
      )
    end
    IosSdksIpaSnapshot.import rows
  end
end
