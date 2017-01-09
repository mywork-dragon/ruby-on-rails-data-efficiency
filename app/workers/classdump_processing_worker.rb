require 'rubygems/package' 

class ClassdumpProcessingWorker
  include Sidekiq::Worker
  include IosClassification

  sidekiq_options retry: false, queue: :classdump_processing

  class NoClassdumpAvailable < RuntimeError; end

  def perform(class_dump_id)
    classdump = ClassDump.find(class_dump_id)
    raise NoClassdumpAvailable unless classdump
    store_summary_data(classdump)
    store_app_content_data(classdump)
    store_marker(classdump)
  end

  def store_summary_data(classdump)
    summary = convert_to_summary(ipa_snapshot_id: classdump.ipa_snapshot_id, classdump: classdump)

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
      info_json = Plist::parse_xml(entry.read)
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

  def store_marker(classdump)
    classdump.store_processed
  end
end
