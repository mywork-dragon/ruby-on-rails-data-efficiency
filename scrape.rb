if(ARGV.length != 2)
  puts "You need 2 arguments."
  puts "1st argument: Notes (must be unique)"
  puts "2nd argument: Max Number of Processes"
  abort
end

notes = ARGV[0]
num_processes = ARGV[1].to_i

directory_name = friendly_filename(notes)

directory_path = "/home/ubuntu/scrape_logs/#{directory_name}"

# Dir.mkdir(directory_path)

num_processes.times do |process_num|
  
  log_path = "#{directory_path}/#{process_num}.log"
  command = "nohup bundle exec rake scraper:scrape_all SCRAPE_PROCESSES=#{num_processes} SCRAPE_PAGE_NUMBER=#{process_num} SCRAPE_JOB_NOTES=\"#{directory_name}\" RAILS_ENV=production > #{log_path} &"
  
  puts "log_path: #{log_path}"
  puts "command: #{command}"
  puts ""
  
  # `#{command}`
  
end

BEGIN {
  
  def friendly_filename(filename)
      filename.gsub(/[^\w\s_-]+/, '')
              .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
              .gsub(/\s+/, '_')
  end

}

