class EpfV2Service

  EPF_USERNAME = 'epfuser99894'
  EPF_PASSWORD = '42413e32cb2759c0e96c9b3cb154c8e2'

  FS = 1.chr
  RS = 2.chr
  DEFAULT_FILE_SPLIT_SIZE = 200

  EPF_CURRENT_URL = 'https://feeds.itunes.apple.com/feeds/epf/v4/current/current/'

  class MissingLink < RuntimeError; end
  class UnexpectedCondition < RuntimeError; end
  class MalformedFilename < RuntimeError; end

  ### START: Entry Point for Loading + Reading EPF Files
  def load_application_device_types
    load_split_file_type(:itunes, 'application_device_type', :read_application_device_types)
  end

  def load_applications
    load_split_file_type(:itunes, 'application', :read_applications)
  end

  def load_storefronts
    load_itunes_file('storefront', :read_storefronts)
  end

  def load_device_types
    load_itunes_file('device_type', :read_device_types)
  end

  def load_split_file_type(type, filename, read_method_sym)
    file_info = download_epf_file(type, filename)
    split_info = split_files(file_info[:filepath])
    chunk_files = fix_files(split_info[:file_prefix], split_info[:dir_path])
    if Rails.env.production?
      batch = Sidekiq::Batch.new
      batch.description = "EPF V2 - Load #{filename}"
      batch.on(
        :complete,
        'EpfV2Service#on_complete_split_reading',
        'dump_directory' => file_info[:dump_dir],
        'load_new_apps' => read_method_sym == :read_applications
      )

      batch.jobs do
        chunk_files.each do |file|
          EpfV2Worker.perform_async(read_method_sym, file)
        end
      end
    else
      file = chunk_files.sample
      send(read_method_sym, file)
      on_complete_split_reading(nil, { 'dump_directory' => file_info[:dump_dir] } )
    end
  end


  ### END: Entry Point for Loading + Reading EPF Files

  ### START: Entry Point for Reading EPF Files

  def read_application_device_types(filepath)
    read_file(filepath, :application_device_type_line_to_row, EpfApplicationDeviceType)
  end

  def read_device_types(filepath)
    read_file(filepath, :device_type_line_to_row, EpfDeviceType)
  end

  def read_applications(filepath)
    read_file(filepath, :application_line_to_row, EpfApplication)
  end

  def read_storefronts(filepath)
    read_file(filepath, :storefront_line_to_row, EpfStorefront)
  end

  ### END: Entry Point for Reading EPF Files

  ### START: line to row conversion methods

  def application_device_type_line_to_row(line)
    columns = split_line_to_columns(line)
    return nil if columns.count != 3
    EpfApplicationDeviceType.new(
      export_date: columns[0],
      application_id: columns[1],
      device_type_id: columns[2]
    )
  end

  def device_type_line_to_row(line)
    columns = split_line_to_columns(line)
    return nil if columns.count != 3
    EpfDeviceType.new(
      export_date: columns[0],
      device_type_id: columns[1],
      name: columns[2]
    )
  end

  def application_line_to_row(line)
    columns = split_line_to_columns(line)
    rows = %i(export_date application_id title recommended_age artist_name seller_name company_url
        support_url view_url artwork_url_large artwork_url_small itunes_release_date
        copyright description version itunes_version download_size)
    row_hash = {}
    rows.each_with_index { |key, index| row_hash[key] = columns[index] }

    if row_hash[:itunes_release_date]
      row_hash[:itunes_release_date] = DateTime.strptime(row_hash[:itunes_release_date], '%Y %m %d')
    end
    row = EpfApplication.new(row_hash)
    row
  end

  def storefront_line_to_row(line)
    columns = split_line_to_columns(line)
    return nil if columns.count != 4
    EpfStorefront.new(
      export_date: columns[0],
      storefront_id: columns[1],
      country_code: columns[2],
      name: columns[3]
    )
  end
  ### END: line to row conversion methods

  ### START: Helper Methods for EPF File Loading

  def load_itunes_file(filename, read_method_sym)
    load_epf_file(:itunes, filename) { |filepath| send(read_method_sym, filepath) }
  end

  def load_pricing_file(filename)
    load_epf_file(:pricing, filename) { |filepath| send(read_method_sym, filepath) }
  end

  ### END: Helper Methods for EPF File Loading

  ### START: Base Methods

  def download_epf_file(type, filename)
    dump_dir = "/tmp/#{filename}_tmp"
    tarball_name = "#{filename}.tbz"
    FileUtils.rm_r(dump_dir) if Dir.exist?(dump_dir)
    Dir.mkdir(dump_dir)

    url = File.join(epf_snapshot_urls[type], tarball_name)
    tarball_path = File.join(dump_dir, tarball_name)

    puts "Downloading file #{filename}"
    File.open(tarball_path, 'wb') do |f_local|
      open(url, http_basic_authentication: [EPF_USERNAME, EPF_PASSWORD]) do |f_remote|
        IO.copy_stream(f_remote, f_local)
      end
    end
    raise UnexpectedCondition unless File.exist?(tarball_path)

    puts "Untarring file #{filename}"
    `tar -xjf #{tarball_path} -C #{dump_dir}`
    filepath = Dir.glob(File.join(dump_dir, '**', '*')).find { |x| /#{filename}\Z/.match(x) }
    raise UnexpectedCondition unless File.exist?(filepath)
    {
      dump_dir: dump_dir,
      filepath: filepath
    }
  end

  def load_epf_file(type, filename)
    file_info = download_epf_file(type, filename)
    yield(file_info[:filepath])
  ensure
    FileUtils.rm_r(file_info[:dump_dir]) if file_info && file_info[:dump_dir] && Dir.exist?(file_info[:dump_dir])
  end

  def epf_snapshot_urls
    html = HTTParty.get(EPF_CURRENT_URL, basic_auth: {username: EPF_USERNAME, password: EPF_PASSWORD}).response.body
    page = Nokogiri::HTML(html)
    links = page.css('a').map { |x| x['href'] }.compact
    %i(itunes match popularity pricing incremental).reduce({}) do |memo, key|
      link = links.find { |x| /#{key}/.match(x) }
      raise MissingLink unless link
      memo[key] = File.join(EPF_CURRENT_URL, link)
      memo
    end
  end

  def split_line_to_columns(line)
    line.strip.gsub(/#{RS}$/, '').split(FS) # get rid of whitespace, the RS suffix, and split by separating character
  end

  def read_file(filepath, line_to_row_method_sym, model)
    puts "Reading file for model #{model.to_s}"
    ActiveRecord::Base.logger.level = 3 if Rails.env.development? # too much output
    index = 0
    rows = []
    File.open(filepath) do |f|
      f.each_line(RS) do |line|
        begin
          next if /^#/.match(line)
        rescue ArgumentError => e
          if e.message.match(/invalid byte sequence/)
            next # allow continuation and skip app
          else
            raise e
          end
        end
        rows << send(line_to_row_method_sym, line)
        index += 1
        if rows.count >= 500
          puts "#{filepath}: #{index}"
          model.import rows.compact
          rows = []
        end
      end
    end

    puts index
    model.import rows.compact if rows.count > 0
  end

  def fix_files(file_prefix, directory_path)
    files = Dir.glob(File.join(directory_path, "**/#{file_prefix}*")).sort
    while files.count > 1
      previous = files.shift
      current = files.first
      current_tmp = "#{current}.tmp"
      File.open(current, 'r') do |f_current|
        File.open(current_tmp, 'w') do |f_tmp|
          File.open(previous, 'a') do |f_previous|
            f_current.gets(RS) # move file pointer to first instance of line break
            pos = f_current.pos
            IO.copy_stream(f_current, f_previous, pos, 0) # copy into previous the bytes from 0 to pos (where first line break is)
            IO.copy_stream(f_current, f_tmp) # copy current into temp file (to delete beginning section)
          end
        end
      end

      FileUtils.mv(current_tmp, current)
    end
    Dir.glob(File.join(directory_path, "**/#{file_prefix}*")).sort
  end

  def on_complete_split_reading(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'Finished EPF file import') if status
    dump_dir = options['dump_directory']
    FileUtils.rm_r(dump_dir) if Dir.exist?(dump_dir)

    if options['load_new_apps']
      puts 'Starting to load new iOS apps'
      self.class.import_ios_apps(automated: true)
      puts 'Kicking off new apps scrape'
      AppStoreSnapshotService.run_new_apps("Run new apps #{Time.now.strftime("%m/%d/%Y")}")
    end
  end

  def split_files(filepath)
    puts "Splitting #{filepath} into #{DEFAULT_FILE_SPLIT_SIZE} files"
    filepieces = filepath.split('/')
    file_prefix = 'chunk_'
    filename = filepieces.pop
    dir_path = File.join(filepieces)
    split_cmd = (Rails.env.production? ? 'split' : 'gsplit')
    `(cd #{dir_path}; #{split_cmd} -n #{DEFAULT_FILE_SPLIT_SIZE} -a #{DEFAULT_FILE_SPLIT_SIZE.to_s.length} -d #{filename} #{file_prefix})`
    {
      dir_path: dir_path,
      file_prefix: file_prefix
    }
  end

  ### END: Base Methods

  class << self

    def clear_tables
      [
        EpfApplication,
        EpfDeviceType,
        EpfStorefront,
        EpfApplicationDeviceType
      ].each do |model|
        puts "Resetting #{model.to_s}: #{model.count} rows"
        ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{model.table_name}")
      end
    end

    def start_epf_files
      clear_tables
      # EpfV2Worker.perform_async(:load_storefronts)
      # EpfV2Worker.perform_async(:load_device_types)

      # Do these one after the other because of server load of downloading
      # EpfV2Worker.new.perform(:load_application_device_types)
      EpfV2Worker.perform_async(:load_applications)
    end

    def import_ios_apps(automated: false)
      apps_count = EpfApplication.joins('LEFT JOIN ios_apps on epf_applications.application_id = ios_apps.app_identifier').where('ios_apps.id is NULL').count


      unless automated
        puts "Apps to be imported: #{apps_count}"
        print 'Continue? [y/n] : '
        return unless gets.include?('y')
      end

      batch_size = 1_000
      EpfApplication.select(:id, :application_id, :itunes_release_date)
        .joins('LEFT JOIN ios_apps on epf_applications.application_id = ios_apps.app_identifier')
        .where('ios_apps.id is NULL')
        .find_in_batches(batch_size: batch_size)
        .with_index do |batch, index|
        puts "App #{index * batch_size}"
        app_rows = batch.map do |epf_application|
          IosApp.new(
            app_identifier: epf_application.application_id,
            released: epf_application.itunes_release_date
          )
        end

        IosApp.import app_rows
      end

      Slackiq.message("Imported #{apps_count} iOS apps from EPF", webhook_name: :main)
    end

    def run_epf_if_feed_available
      if new_feed_available?
        Slackiq.message("A new EPF feed is available!", webhook_name: :main)
        EpfFullFeed.create!(name: current_feed_name)
        start_epf_files
      else
        Slackiq.message("There is no new EPF Feed available. Guess we'll try again tomorrow.", webhook_name: :main)
      end
    end

    def current_feed_name
      urls = new.epf_snapshot_urls
      itunes_file_name = urls[:itunes].split('/').last
      date_match = /itunes(\d+)/.match(itunes_file_name)
      raise MalformedFilename unless date_match
      date_match[1]
    end

    def new_feed_available?
      last_feed_date = Date.parse(EpfFullFeed.last.name)
      Date.parse(current_feed_name) > last_feed_date
    end
  end
end
