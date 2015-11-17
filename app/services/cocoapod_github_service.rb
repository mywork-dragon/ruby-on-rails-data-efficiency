class CocoapodGithubService

	class << self

		def update_cocoapods

      start_time = DateTime.now
			dump = Rails.env.production? ? '/mnt/cocoapods/latest/' : '../cocoapods/latest/'
			should_update, new_version, last_version = update_status(dump)

			return nil unless should_update
		  basename = new_version.to_s
		  filename = dump + basename + '.zip' 
		  download_cocoapod(filename)
		  Dir.mkdir dump + basename
		  extract_files(filename, dump, basename)
		  files = diff_files(old_file: dump+last_version.to_s, new_file: dump+basename)

		  files.each do |file|
		  	records = all_files_from_dir(dump + basename + '/' + file)
		  	next if records.blank?
		  	records.each do |record|
		  		next if File.extname(record) != '.json'
		  		save_podspec(record)
		  	end
		  end
		  File.delete(filename)
      FileUtils.rm_rf(dump+last_version.to_s)

      download_source_code(start_time)
		end

		def update_status(dump)
			page = Proxy.get(req: 'https://github.com/CocoaPods/Specs')
			new_version = Nokogiri::HTML(page.body).xpath("//li[@class=\"commits\"]").search('.num').inner_html.strip.gsub(',','').to_i
			last_version = File.basename(Dir.glob(dump + '/*').first).to_i
			File.open('cocoapod.version', 'wb') { |f| f.write new_version }
			should_update = new_version > last_version
			puts should_update ? "Version is out of date. Updating now." : "Version is up to date."
			return should_update, new_version, last_version
		end

		def download_cocoapod(filename)
		  headers = {
		    'Content-Type' => 'application/zip',
		    'User-Agent' => UserAgent.random_web 
		  }
			uri = URI('https://codeload.github.com/CocoaPods/Specs/zip/master')
		  data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers})
		  File.open(filename, 'wb') { |f| f.write data.body }
		end

		def extract_files(filename, dump, basename)
			Zip::ZipFile.open(filename) do |zip_file|
		      zip_file.each do |entry|
		        entry.extract( dump + basename + '/' + entry.name )
		      end
		    end
		end

		def diff_files(old_file:, new_file:)
			d = diff_dirs old_file, new_file
			d.select{|k,v| k == :new }.map{|k,v|v}
		end

		def all_files_from_dir(dir_path)
			records = Dir.glob(dir_path + '/*')
			all_files = []
			records.each do |record|
				all_files << find_file(record)
			end
			all_files << dir_path if File.file?(dir_path)
			all_files
		end

		def find_file(record)
			if File.file?(record)
				record
			elsif File.directory?(record)
				Dir.glob(record + '/*').first
			end
		end

    def save_podspec(filename)
      file = File.open(filename).read
      r = JSON.parse(file)
      begin
        s = r['source']
        git = s['git']
        http = s['http']
        tag = s['tag']
        summ = r['summary']
        link = r['homepage']
        name = r['name']
        ver = r['version']

        cp = Cocoapod.create(git: git, http: http, tag: tag, summary: summ, link: link, name: name, version: ver)
        r['authors'].each do |name, email|
          CocoapodAuthor.find_or_create_by(name: name, email: email, cocoapod: cp)
        end

        r['tags'].each do |tag|
          CocoapodTag.create(tag: tag, cocoapod: cp)
        end
      rescue
        nil
      end
    end

    def download_source_code(start_time)
      Cocoapod.where('created_at > ?', start_time).each do |cocoapod|
        puts "     - #{cocoapod.name} (#{cocoapod.version})"
        download_source(cocoapod.id)
      end
    end

    def download_source(cocoapod_id)
      cocoapod = Cocoapod.find_by_id(cocoapod_id)
      url = cocoapod.http
      source_code_url = if url.blank?
        url = cocoapod.git
        company = url[/.com+[^a-zA-Z](?!.*.com+[^a-zA-Z])(.*?)\//,1]
        repo = url[/#{company}\/(.*?)\./,1]
        'https://codeload.github.com/' + company + '/' + repo + '/zip/master'
      else
        url.gsub(/(?<=.zip).+/,'')
      end
      return nil if cocoapod.nil? || source_code_url.nil?
      basename = cocoapod.name
      dump = Rails.env.production? ? '/mnt/cocoapods/source_code' : '../cocoapods/source_code'
      filename = dump + basename + '.zip'
      headers = {
        'Content-Type' => 'application/zip',
        'User-Agent' => UserAgent.random_web
      }
      uri = URI(source_code_url)
      data = Proxy.get(req: {:host => uri.host, :path => uri.path, :protocol => uri.scheme, :headers => headers})
      File.open(filename, 'wb') { |f| f.write data.body }
      Dir.mkdir dump + basename
      Zip::ZipFile.open(filename) do |zip_file|
        zip_file.each do |entry|
          entry.extract( dump + basename + '/' + entry.name )
          if File.extname(entry.name) == '.h'
            parse_header(filename: dump + basename + '/' + entry.name, cocoapod_id: cocoapod_id)
          end
        end
      end
      File.delete(filename)
      FileUtils.rm_rf(dump+basename)
    end

    def parse_header(filename:, cocoapod_id:)
      return nil unless File.exist? filename
      file = File.open(filename).read
      names = file.scan(/(@interface|@protocol)\s(.*?)[^a-zA-Z]/i).uniq
      names.each do |name|
        next if in_apple_docs?(name[1]) || name[1].blank?
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

end