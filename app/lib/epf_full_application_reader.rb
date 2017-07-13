# DEPRECATED - now using feeds service via EpfApplicationLoader
class EpfFullApplicationReader

  class CommentLine; end
  class InvalidLine; end
  class ExistingApp; end

  FS = 1.chr
  RS = 2.chr

  def initialize(download_url = nil)
    @filename = 'application.tbz'
    @download_url = nil
  end

  def find_download_url
    return @download_url if @download_url
    itunes = AppleEpf.current_urls[:itunes]
    @download_url = File.join(itunes, @filename)
  end

  def download!
    puts 'downloading'
    @filepath = File.join('/tmp', @filename)
    AppleEpf.download!(@download_url, @filepath)
    @filepath
  end

  def untar!
    puts 'untarring'
    f = @filename.split('.').first
    @dumppath = File.join('/tmp', "#{f}_dump")
    Dir.mkdir(@dumppath)
    `tar -xjf #{@filepath} -C #{@dumppath}`
    @untarred_file = Dir.glob(File.join(@dumppath, '**', '*')).find { |x| /#{f}\Z/.match(x) }
  end

  def teardown!
    puts 'teardown'
    FileUtils.rm(@filepath) if @filepath && File.exist?(@filepath)
    FileUtils.rm_rf(@dumppath) if @dumppath && Dir.exist?(@dumppath)
  end

  def build_existing
    @existing_identifiers = Set.new(IosApp.pluck(:app_identifier))
  end

  def line_to_app(line)
    # get rid of whitespace, the RS suffix, and split by separating character
    columns = line.strip.gsub(/#{RS}$/, '').split(FS)

    rows = %i(export_date application_id title recommended_age artist_name seller_name company_url
        support_url view_url artwork_url_large artwork_url_small itunes_release_date
        copyright description version itunes_version download_size)
    row_hash = {}
    rows.each_with_index { |key, index| row_hash[key] = columns[index] }

    if row_hash[:itunes_release_date]
      row_hash[:itunes_release_date] = DateTime.strptime(row_hash[:itunes_release_date], '%Y %m %d')
    end

    IosApp.new(
      app_identifier: row_hash[:application_id],
      released: row_hash[:itunes_release_date],
      source: :epf_weekly
    )
  end

  def extract_app(line)
    return CommentLine if /^#/.match(line)
    ios_app = line_to_app(line)
    @existing_identifiers.include?(ios_app.app_identifier) ? ExistingApp : ios_app
  rescue ArgumentError => e
    if e.message.match(/invalid byte sequence/)
      return InvalidLine
    else
      raise e
    end
  end

  def load_apps
    puts 'load apps'
    index = 0
    rows = []
    File.open(@untarred_file) do |f|
      f.each_line(RS) do |line|
        app = extract_app(line)
        next if [CommentLine, InvalidLine, ExistingApp].include?(app)
        rows << app
        index += 1
        if rows.count >= 10_000
          puts "Application ##{index}"
          IosApp.import rows.compact
          rows = []
        end
      end
    end

    puts index
    IosApp.import rows.compact if rows.count > 0
  end

  def execute
    find_download_url
    download!
    untar!
    build_existing
    load_apps
  ensure
    teardown!
  end
end
