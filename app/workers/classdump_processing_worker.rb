require 'rubygems/package' 

class ClassdumpProcessingWorker
  include Sidekiq::Worker
  include IosClassification

  sidekiq_options retry: false, queue: :classdump_processing

  class NoClassdumpAvailable < RuntimeError; end

  MAX_WAIT_ATTEMPTS = 20

  attr_writer :jtool

  def jtool
    @jtool || Jtool.new
  end

  def perform(class_dump_id)
    classdump = ClassDump.find(class_dump_id)
    raise NoClassdumpAvailable unless classdump
    store_summary_data(classdump)
    store_app_content_data(classdump)
    store_binary_data(classdump)
    store_marker(classdump)
  end

  def get_summary_with_wait(classdump)
    summary = nil
    attempts = 0

    while summary.nil? && attempts < MAX_WAIT_ATTEMPTS
      begin
        summary = convert_to_summary(ipa_snapshot_id: classdump.ipa_snapshot_id, classdump: classdump)
      rescue IosClassification::UnavailableClassdump
        puts "#{classdump.id}: Failed attempt #{attempts}"
        attempts += 1
        sleep 1
        classdump.reload # fetch the latest for remote updates
      end
    end

    raise NoClassdumpAvailable unless summary

    summary
  end

  def store_summary_data(classdump)
    summary = get_summary_with_wait(classdump)

    classdump.store_classdump_txt(summary['binary']['classdump'])

    classes = classes_from_classdump(summary['binary']['classdump'])
    classdump.store_classes(classes)

    classdump.store_strings(summary['binary']['strings'])

    packages = bundles_from_strings(summary['binary']['strings'])
    classdump.store_packages(packages)

    classdump.store_files(summary['files'])
    classdump.store_frameworks(summary['frameworks'])
  end
  
  def store_app_content_data(classdump)
    return unless classdump.app_content.present?
    extract_app_content(classdump) do |tgz|
      save_plist(classdump, tgz)
    end
  end

  def save_plist(classdump, tgz)
    tgz_regex_seek(tgz, %r{\.app/Info\.plist$}) do |entry|
      contents = entry.read.encode('utf-8', {invalid: :replace, undef: :replace})
      info_json = Plist::parse_xml(contents)
      info_json['id'] = classdump.id
      classdump.store_plist(info_json)
    end
  end

  # same as #tgz.seek but uses regex instead
  def tgz_regex_seek(tgz, regex)
    found = nil
    tgz.each_entry do |entry|
      if regex.match(entry.full_name)
        found = entry
        break
      end
    end
    return unless found

    return yield found
  ensure
    tgz.rewind
  end

  def extract_app_content(classdump)
    url = classdump.app_content.url
    contents = open(url)
    yield Gem::Package::TarReader.new(Zlib::GzipReader.new(contents))
  ensure
    contents.close
  end

  def store_binary_data(classdump)
    combined = combined_binary_data(classdump)
    classdump.store_jtool_classes(combined[:classes])
    classdump.store_shared_libraries(combined[:libraries])
  end

  def combined_binary_data(classdump)
    binaries = classdump.list_decrypted_binaries.contents
    summaries = binaries.map do |binary|
      binary_data(classdump, binary.key)
    end

    classes = summaries.map { |s| s[:classes] }.flatten.uniq
    libraries = summaries.map { |s| s[:libraries] }.flatten.uniq

    {
      classes: classes,
      libraries: libraries
    }
  end

  def binary_data(classdump, binary_key)
    file_path = File.join('/tmp', Digest::SHA1.hexdigest(binary_key))
    classdump.download_binary(binary_key, file_path)
    {
      classes: jtool.objc_classes(file_path),
      libraries: jtool.shared_libraries(file_path)
    }
  ensure
    File.delete(file_path) if file_path && File.exist?(file_path)
  end

  def store_marker(classdump)
    classdump.store_processed
  end

  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Processed all classdumps')
  end

  class << self

    def process_all
      ids = ClassDump.where(dump_success: true).pluck(:id)
      batch = Sidekiq::Batch.new
      batch.description = 'Re-processing ALL classdumps'
      batch.on(:complete, 'ClassdumpProcessingWorker#on_complete')

      batch.jobs do
        ids.each do |id|
          print '.'
          ClassdumpProcessingWorker.perform_async(id)
        end
      end

      puts 'Queued'
    end

  end
end
