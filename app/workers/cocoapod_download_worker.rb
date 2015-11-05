class CocoapodDownloadWorker

  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default

  DUMP_PATH = Rails.env.production? ? File.join(`echo $HOME`.chomp, 'sdk_dump') : '/tmp/sdk_dump/'
  BACKTRACE_SIZE = 5

  def perform(cocoapod_id)
    begin
      download_source(cocoapod_id)
    rescue => e

      
      if Rails.env.production?
        backtrace = e.backtrace[0...BACKTRACE_SIZE].join(' ---- ')

        CocoapodException.create!({
          cocoapod_id: cocoapod_id,
          error: e.message,
          backtrace: backtrace
        })
      end

      FileUtils.rm_rf(File.join(DUMP_PATH, cocoapod_id.to_s))
      raise e
    end
  end

  # Downloads source to directory DUMP_PATH + cocoapod_id, parses headers,
  # and uploads results to source data table.
  def download_source(cocoapod_id)

    cocoapod = Cocoapod.find_by_id(cocoapod_id)

    raise "No download information available for pod #{cocoapod.id}" if cocoapod.http.nil? && cocoapod.git.nil? #should delete?

    url = cocoapod.http

    source_code_url = if url.blank?

      url = cocoapod.git

      raise "not a valid url #{url}" if url.match(/^git@/)

      if url.match('bitbucket')
        url.gsub(/\.git$/, '') + '/get/master.zip'
      else # github
        parts = url.split('/')
        repo = parts.pop.gsub(/\.git$/, '')
        company = parts.pop

        'https://codeload.github.com/' + company + '/' + repo + '/zip/master'
      end

    else

      url.gsub(/(?<=.zip).+/,'')

    end

    raise "No cocoapod or no source_code_url: #{source_code_url}" if cocoapod.nil? || source_code_url.nil?

    dump = File.join(DUMP_PATH, cocoapod_id.to_s)

    Dir.mkdir(dump)   

    headers = {
      'Content-Type' => 'application/zip',
      'User-Agent' => UserAgent.random_web
    }
    begin
      uri = URI(source_code_url)
    rescue
      raise "#{source_code_url} is not a valid URI"
    end

    puts "starting request"

    data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers})

    puts "done with request"

    # if response failed, exit
    if data.status < 200 || data.status >= 300
      # Cocoapod.delete(cocoapod.id) if data.status == 404 && !url.blank?
      raise "No source code found at #{source_code_url} with status code: #{data.status}"
    end

    ext = File.extname(source_code_url)
    ext = '.zip' if ext.blank?

    unzipped_file = nil
    filename = File.join(dump, cocoapod_id.to_s + ext)

    File.open(filename, 'wb') { |f| f.write data.body }

    # different encodings
    if ext == ".tgz" || ext == ".gz"

      unzipped_file = filename.gsub(/#{ext}$/, '')
      Dir.mkdir(unzipped_file)
      `tar -xzf #{filename} -C #{unzipped_file}`
    elsif ext == ".bz2"

      unzipped_file = filename.gsub(/#{ext}$/, '')
      Dir.mkdir(unzipped_file)
      `tar -xjf #{filename} -C #{unzipped_file}`
    else
      Zip::ZipFile.open(filename) do |zip_file|

        # get root directory it extracts to. If doesn't have one, create one related to cocoapod id
        nested_sort = zip_file.entries.sort do |a, b|
          if a.name.count('/') == a.name.count('/')
            a.name.split('/').length <=> b.name.split('/').length
          else
            a.name.count('/') <=> b.name.count('/')
          end
        end
        prefix = ''

        has_root = nested_sort.first.name.split('/').length < nested_sort.second.name.split('/').length ? true : false

        if has_root
          unzipped_file = File.join(dump, nested_sort.first.name)
        else
          unzipped_file = File.join(dump, cocoapod_id.to_s)
          prefix = cocoapod_id.to_s
        end

        Dir.mkdir(unzipped_file)
        zip_file.each do |entry|
          begin
            entry.extract(File.join(dump,prefix,entry.name))
          rescue
            puts "Missed a file"
          end
        end

      end
    end


    raise "Could not unzip file #{unzipped_file}" if unzipped_file.nil?
    files = get_source_files(cocoapod, unzipped_file)
    
    files.each do |file|
      next if File.extname(file) == '.m'
      parse_header(filename: file, cocoapod_id: cocoapod_id, ext: File.extname(file))
    end

    FileUtils.rm_rf(dump) if unzipped_file

  end

  def get_source_files(cocoapod, root_path)

    all_files = Dir.glob("#{root_path}/**/*.{h,swift}").uniq
    return all_files if cocoapod.json_content.nil?

    podspec = JSON.parse(cocoapod.json_content)

    to_inspect = [podspec]
    globs = []
    properties = ["source_files", "public_header_files"]

    while to_inspect.length > 0
      spec = to_inspect.shift

      properties.each do |prop|

        if !spec[prop].nil?
          globs.push(spec[prop]) if spec[prop].class == String
          globs.concat(spec[prop]) if spec[prop].class == Array
        end
      end

      to_inspect.concat(spec["subspecs"]) if !spec["subspecs"].nil?
    end

    files = globs.map { |glob| Dir.glob(File.join(root_path, glob)) }.flatten do |file|

      if File.directory?(file)
        Dir.entries(file).map {|f| File.join(file, f)}.select {|f| File.file?(f)}
      else
        [file]
      end
    end.flatten.uniq

    if files.empty?
      all_files
    else
      files
    end
  end

  def parse_header(filename:, cocoapod_id:, ext:)

    return nil if !File.exist?(filename) || File.directory?(filename)

    file = File.open(filename).read.scrub

    if ext == '.h'
      names = file.scan(/(@interface|@protocol)\s(.*?)[^a-zA-Z]/i).uniq  
    elsif ext == '.swift'
      names = file.scan(/^public\s+(class|protocol|struct)\s+(.*?)[^a-zA-Z]/i).uniq
    else
      names = []
    end

    names.each do |name|
      next if name[1] == ''

      next if Rails.env.production? && (in_apple_docs?(name[1]) || name[1].blank?)

      begin

        CocoapodSourceData.find_or_create_by(name: name[1], cocoapod_id: cocoapod_id)

      rescue

        nil

      end

    end

  end

  def in_apple_docs?(q)

    apple_docs = AppleDoc.find_by_name(q)

    return true if apple_docs.present?

    uri = URI("https://developer.apple.com/search/search_data.php")

    headers = { 'User-Agent' => UserAgent.random_web }

    data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers}, params: {'q' => q})

    in_docs = JSON.parse(data.body).any?{ |res| res['description'].downcase.include? q.downcase }

    if in_docs

      AppleDoc.create(name: q)

      true

    else

      false

    end

  end
end