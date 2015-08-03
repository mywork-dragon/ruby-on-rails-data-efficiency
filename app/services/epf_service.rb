class EpfService

  EPF_USERNAME = 'epfuser99894'
  EPF_PASSWORD = '42413e32cb2759c0e96c9b3cb154c8e2'

  NUMBER_OF_FILES = 10 # Should be less than or equal to the number of threads
  
  FS = 1.chr
  RS = 2.chr + "\n"
  
  if Rails.env.production?
    EPF_DIRECTORY = '/home/deploy/epf'
  else
    EPF_DIRECTORY = '/Users/jason/penpals/epf/epf_service'
  end
  

  class << self
    
    
    def run_itunes_current
      urls = epf_snapshot_urls
      
      run_feed(file_url: urls[:current][:itunes_tbz], feed_symbol: :itunes, name: urls[:current][:name])
    end
    
    def files_for_feed(feed_symbol)
      case feed_symbol
      when :itunes
        %w(application)
      when :match
        raise '"match" not implemented'
      when :popularity
        raise '"popularity" not implemented'
      when :pricing
        raise '"pricing not implemented"'
      end
    end
    
    # Valid feed symbols: :itunes, :match, :popularity, :pricing
    def run_feed(file_url:, feed_symbol:, name:)
      #TODO: call everything
          
      saved_file_path = EPF_DIRECTORY + '/' + file_url.split('/').last
      download(file_url, saved_file_path)

      puts 'Download done!'
      
      tbz_name = "#{feed_symbol.to_s}#{name}.tbz"
      saved_file_path = "#{EPF_DIRECTORY}/#{tbz_name}"
      
      puts "saved_file_path: #{saved_file_path}"
      
      unzip(saved_file_path)
      
      files_for_feed(feed_symbol).each do |file|
        file_path = "#{epf_directory}/#{tbz_name.gsub('.tbz', '')}"
        puts file_path
        split(file_path)
      
        fix_partials
      end      
      
    end
    
    # Oldest is first
    # current: The current snapshots
    # all: All snapshots
    def epf_snapshot_urls
      prefix = 'https://feeds.itunes.apple.com/feeds/epf/v3/full/'
      html = HTTParty.get(prefix, basic_auth: {username: EPF_USERNAME, password: EPF_PASSWORD}).response.body
      page = Nokogiri::HTML(html)
      
      
      all_names = page.css('a').map{ |x| x['href'] }.compact.select{ |x| x.match(/\d+\//)}.map{ |x| x.gsub('/', '') } 
      all = all_names.map do |name| 
        {
          name: name,
          itunes_tbz: "#{prefix}#{name}/itunes#{name}.tbz",
          match_tbz: "#{prefix}#{name}/match#{name}.tbz", 
          popularity_tbz: "#{prefix}#{name}/popularity#{name}.tbz", 
          pricing_tbz: "#{prefix}#{name}/pricing#{name}.tbz"
        } 
      end
      
      current = all.last
      
      {current: current, all: all}
    end
    
    # Download the latest version of the EPF
    def download(file_url, saved_file_path)
      `curl --user #{EPF_USERNAME}:#{EPF_PASSWORD} #{file_url} > #{saved_file_path}`
    end
    
    def unzip(file)
      `tar -xvf #{file}`
    end
    
    def split(filename)
      split_cmd = (Rails.env.production? ? 'split' : 'gsplit')
      file = "#{EPF_DIRECTORY}/#{filename}"
      `(cd #{EPF_DIRECTORY}; #{split_cmd} -n #{NUMBER_OF_FILES} -a #{number_of_digits} -d #{file} #{filename}_)`
    end
    
    def fix_partials(main_file_name)
      
      (NUMBER_OF_FILES - 1).times do |n|        #don't do the last file
        split_file = file_for_n(n: n, filename: main_file_name)
      
        next_split_file = file_for_n(n: n + 1, filename: main_file_name)
      
        partial_data = get_partial_data_from_end(split_file)
      
        add_partial_data_to_beginning(partial_data, next_split_file)
      
      end
    end
    
    # Gets it and removes it
    def get_partial_data_from_end(file)
      max_lines = 5e3
      
      file_s = File.open(file, "rb:UTF-8").read
      
      file_s_split = file_s.split(RS)
      
      file_s_trimmed = file_s_split[0..(file_s_split.size - 2)].join(RS) + RS #remove the last element
      
      File.open(file, 'w') { |file| file.write(file_s_trimmed.encode('UTF-8', {invalid: :replace, undef: :replace, replace: ''})) }
      
      file_s_split.last
    end
    
    def add_partial_data_to_beginning(partial_data, file)
      original_file = file
      new_file = original_file + '.new'
      
      File.open(new_file, 'w:UTF-8') do |fo|
        
        fo.print partial_data.to_s.encode('UTF-8', {invalid: :replace, undef: :replace, replace: ''})
        File.foreach(original_file) do |li|
          fo.puts li
        end
      end
      
      File.rename(original_file, original_file + '.old')
      File.rename(new_file, original_file)
      File.delete(original_file + '.old')
    end
    
    private
    
    def number_of_digits
      NUMBER_OF_FILES.to_s.length
    end
    
    def file_for_n(n:, filename:)
      suffix = n.to_s.rjust(number_of_digits, '0')
      EPF_DIRECTORY + '/' + filename + '_' + suffix
    end
    
  end

end