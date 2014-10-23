if(ARGV.length != 2)
  puts "You need 2 arguments."
  puts "1st argument: Notes (must be unique)"
  puts "2nd argument: Number of Processes"
  abort
end

notes = ARGV[0]
num_processes = ARGV[1].to_i

# Dir.mkdir("dummy_folder")

notes_filename = friendly_filename(notes)
puts "notes_filename: #{notes_filename}"

num_process.times do |process_num|
  
  command = "nohup bundle exec rake scraper:scrape_all SCRAPE_PROCESSES=#{num_processes} SCRAPE_PAGE_NUMBER=#{process_num} SCRAPE_JOB_NOTES=#{notes} RAILS_ENV=production > /dev/null 2>&1"
  
end

BEGIN {
  
  def friendly_filename(filename)
      filename.gsub(/[^\w\s_-]+/, '')
              .gsub(/(^|\b\s)\s+($|\s?\b)/, '\\1\\2')
              .gsub(/\s+/, '_')
  end

}

