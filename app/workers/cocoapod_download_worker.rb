class CocoapodDownloadWorker

	include Sidekiq::Worker

	sidekiq_options :retry => 2, queue: :scraper

	def download_source(cocoapod_id)

	  cocoapod = Cocoapod.find_by_id(cocoapod_id)

	  return "No download information available for pod #{cocoapod.id}" if cocoapod.http.nil? && cocoapod.git.nil? #should delete?

	  url = cocoapod.http

	  source_code_url = if url.blank?

	    url = cocoapod.git

	    return "not a valid url #{url}" if url.match(/^git@/)

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

	  return nil if cocoapod.nil? || source_code_url.nil?

	  basename = cocoapod.name

	  dump = Rails.env.production? ? '/mnt/sdk_dump/' : '../sdk_dump/'

	  headers = {
	    'Content-Type' => 'application/zip',
	    'User-Agent' => UserAgent.random_web
	  }
	  begin
	    uri = URI(source_code_url)
	  rescue
	    return "#{source_code_url} is not a valid URI"
	  end

	  puts "starting request"

	  data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers})

	  puts "done with request"

	  # if response failed, exit
	  if data.status < 200 || data.status >= 300
	    # Cocoapod.delete(cocoapod.id) if data.status == 404 && !url.blank?
	    return "No source code found at #{source_code_url}"
	  end

	  ext = File.extname(source_code_url)
	  ext = '.zip' if ext.blank?

	  unzipped_file = nil
	  filename = dump + cocoapod.name + ext 

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
	    begin
	      Zip::ZipFile.open(filename) do |zip_file|

	        # get base directory it extracts to. If doesn't have one use cocoapod's name
	        root_file = zip_file.entries.map{|x| x.name}.sort_by {|x| x.count('/')}.first
	        prefix = ''

	        # some files extract in current directory, some don't
	        if root_file.count('/') < 1
	          unzipped_file = File.join(dump, cocoapod.name)
	          prefix = cocoapod.name
	        else
	          unzipped_file = dump + zip_file.entries.first.name.split('/').first
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
	    rescue => e
	      return "malformed zip file" if e.message.match('signature not found')
	      raise e
	    end
	  end

	  return nil if unzipped_file.nil?

	  podspec = Dir.glob("#{unzipped_file}/**/*.podspec").sort_by {|x| x.count('/')}.first

	  if podspec.nil?
	    files = Dir.glob("#{unzipped_file}/**/*.{h,swift}").uniq
	  else
	    contents = File.open(podspec).read

	    globs = contents.scan(/(source_files|public_header_files)\s*=(.*)\n/).map{|k, v| v.chomp}

	    globs = globs.map{|x| x.scan(/['"]{1}([^'"]+)['"]{1}/).flatten }.flatten

	    files = globs.map{|glob| Dir.glob(File.dirname(podspec)+'/'+glob) }.flatten

	    files = files.map do |file|
	      if File.directory?(file)
	        Dir.entries(file).map {|f| File.join(file, f)}.select {|f| File.file?(f)}
	      else
	        [file]
	      end
	    end.flatten.uniq
	  end

	  files.each do |file|
	    next if File.extname(file) == '.m'
	    parse_header(filename: file, cocoapod_id: cocoapod_id, ext: File.extname(file))
	  end

	  File.delete(filename)

	  FileUtils.rm_rf(unzipped_file)

	end

	def parse_header(filename:, cocoapod_id:, ext:)

	  return nil if !File.exist?(filename) || File.directory?(filename)

	  file = File.open(filename).read.scrub

	  if ext == '.h'
	    names = file.scan(/(@interface|@protocol)\s(.*?)[^a-zA-Z]/i).uniq  
	  elsif ext == '.swift'
	    names = file.scan(/^public\s+(class|protocol|struct)\s(.*?)[^a-zA-Z]/i).uniq
	  else
	    names = []
	  end

	  names.each do |name|

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