class CocoapodDownloadWorker

  include Sidekiq::Worker

  sidekiq_options :retry => 2, queue: :default

  DUMP_PATH = Rails.env.production? ? File.join(`echo $HOME`.chomp, 'sdk_dump') : '/tmp/sdk_dump/'
  BACKTRACE_SIZE = 10

  def perform(cocoapod_id)
    begin
      download_source(cocoapod_id)
    rescue => e

      CocoapodException.create!({
        cocoapod_id: cocoapod_id,
        error: e.message,
        backtrace: e.backtrace
      })

      FileUtils.rm_rf(File.join(DUMP_PATH, cocoapod_id.to_s))
      raise e
    end
  end

  # Downloads source to directory DUMP_PATH + cocoapod_id, parses headers,
  # and uploads results to source data table.
  def download_source(cocoapod_id)

    cocoapod = Cocoapod.find_by_id(cocoapod_id)

    raise "No cocoapod available by id #{cocoapod_id}" if cocoapod.nil?
    raise "No download information available for pod #{cocoapod.id}" if cocoapod.http.nil? && cocoapod.git.nil? #should delete?

    url = cocoapod.http
    ext = nil

    source_code_url = if url.blank?

      url = cocoapod.git

      raise "not a valid url #{url}" if url.match(/^git@/)

      if url.match('bitbucket')

        if !cocoapod['tag'].nil?
          url = url.gsub(/\.git$/, '') + "/get/#{cocoapod['tag']}.tar.gz"
          ext = '.gz'
        else
          url = url.gsub(/\.git$/, '') + '/get/master.tar.gz'
          ext = '.gz'
        end

      else # github
        parts = url.split('/')
        repo = parts.pop.gsub(/\.git$/, '')
        company = parts.pop

        url = 'https://codeload.github.com/' + company + '/' + repo + '/zip/master'
        ext = '.zip'

        # Get the tarball_url
        if !cocoapod['tag'].nil?
          tags = GithubService.get_tags([company, repo].join('/'))
          tag = tags.select{|data| data['name'] == cocoapod['tag']}.first
          if !tag.nil?
            url = tag['tarball_url'] if !tag.nil?
            ext = '.gz'
          end
        end
      end

      url

    else

      url.gsub(/(?<=.zip).+/,'')

    end

    raise "Source code url could not be created for cocoapod: #{cocoapod_id}" if source_code_url.nil?

    ext = ext || File.extname(source_code_url)
    ext = '.zip' if ext.blank? # fallback


    dump = File.join(DUMP_PATH, cocoapod_id.to_s)

    Dir.mkdir(dump)   

    begin
      uri = URI(source_code_url)
    rescue
      raise "#{source_code_url} is not a valid URI"
    end

    headers = {
      'Content-Type' => 'application/zip',
      'User-Agent' => UserAgent.random_web
    }

    puts "starting request"

    if source_code_url.include?('api.github.com')
      # do this manually because need special procedure block
      acct = GithubService.get_credentials
      params = {
        'client_id' => acct[:client_id],
        'client_secret' => acct[:client_secret]
      }
      data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers}, params: params) do |curb|
        curb.follow_location = true
        curb.max_redirects = 50
      end
    else
      data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers}) do |curb|
        curb.follow_location = true
        curb.max_redirects = 50
      end
    end

    puts "done with request"

    # if response failed, exit
    if data.status < 200 || data.status >= 300
      # Cocoapod.delete(cocoapod.id) if data.status == 404 && !url.blank?
      raise "No source code found at #{source_code_url} with status code: #{data.status}"
    end

    unzipped_file = nil
    filename = File.join(dump, cocoapod_id.to_s + ext)

    File.open(filename, 'wb') { |f| f.write data.body }

    # different encodings
    if ext == ".tgz" || ext == ".gz" || ext == ".bz2"

      flags = ext == ".bz2" ? "xjf" : "xzf"

      unzipped_file = filename.gsub(/#{ext}$/, '')
      Dir.mkdir(unzipped_file)
      `tar -#{flags} #{filename} -C #{unzipped_file}`

      # sometimes has a root directory, sometimes not
      opened = `ls #{unzipped_file}`.chomp.split("\n")
      if opened.length == 1
        unzipped_file = File.join(unzipped_file, opened.first)
      end
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

        # sometimes everything is contained in a root file
        has_root = nested_sort.map {|entry| entry.name.split('/').first}.uniq.length == 1 ? true : false

        if has_root
          unzipped_file = File.join(dump, nested_sort.first.name.split('/').first)
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

    FileUtils.rm_rf(dump)

  end

  # safely get data nested in JSON object.
  # @param json - a JSON object
  # @param props - a string of properties, separated by periods (ex. 'parent.child1.child2')
  # returns the value at the nested property if it exists, nil otherwise
  def get_from_json(json:, props:)
    list = props.split(".")
    data = json
    while list.length > 0
      prop = list.shift
      data = data ? data[prop] : nil
    end

    data
  end

  def get_source_files(cocoapod, root_path, v2: true)
    all_files = Dir.glob("#{root_path}/**/*.{h,swift}").uniq
    return all_files if cocoapod.json_content.nil?

    podspec = JSON.parse(cocoapod.json_content)

    to_inspect = [podspec]
    globs = []
    properties = v2 ? ['source_files', 'public_header_files', 'vendored_frameworks', 'ios.source_files', 'ios.public_header_files', 'ios.vendored_frameworks'] : ['source_files', 'public_header_files']

    while to_inspect.length > 0
      spec = to_inspect.shift

      properties.each do |prop|
        entry = get_from_json(json: spec, props: prop)
        if !entry.nil?
          globs.push(entry) if entry.class == String
          globs.concat(entry) if entry.class == Array
        end
      end

      to_inspect.concat(spec["subspecs"]) if !spec["subspecs"].nil?
    end

    files = globs.map { |glob| Dir.glob(File.join(root_path, glob)) }.flatten.map do |file|

      if File.directory?(file)
        v2 ? Dir.glob(File.join(file, '**/*.{h, swift}')).select {|f| File.file?(f)} : Dir.entries(file).map {|f| File.join(file, f)}.select {|f| File.file?(f)}
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

      next if Rails.env.production? && (name[1].blank? || in_apple_docs?(name[1]))

      begin

        CocoapodSourceData.find_or_create_by(name: name[1], cocoapod_id: cocoapod_id)

      rescue

        nil

      end

    end

  end

  def in_apple_docs?(q)

    return false # For now, ignore apple docs. Come back to it later

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