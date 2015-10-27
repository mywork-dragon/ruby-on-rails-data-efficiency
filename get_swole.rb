#!/usr/bin/env ruby

begin
  require 'colorize'
rescue => e
  puts "\nYou need to install the colorize gem to get swole."
  puts "gem install colorize"
  abort
end

swole_string = %q(

 ___  _                 _                    _                     _       _ 
|_ _|<_>._ _ _  ___   _| |_ ___   ___  ___ _| |_   ___ _ _ _  ___ | | ___ | |
 | | | || ' ' |/ ._>   | | / . \ / . |/ ._> | |   <_-<| | | |/ . \| |/ ._>|_/
 |_| |_||_|_|_|\___.   |_| \___/ \_. |\___. |_|   /__/|__/_/ \___/|_|\___.<_>
                                 <___'

)                                       

puts swole_string.light_yellow

puts "\nWhich servers would you like to deploy to?\n\n"
puts "Options"
puts "-------"
puts "scraper".light_cyan + ": Deploys to the main scraper servers."
puts "sdk_scraper".light_cyan + ": Deploys to the SDK scraper servers."
puts "sdk_scraper_live_scan".light_cyan + ": Deploys to the SDK scraper live scan."
puts "staging:".light_cyan + " Deploys to the staging server."
puts "web".light_cyan + ": Deploys to the Web server."
puts "darth_vader".light_cyan + ": Deploys to Vader."
puts "\n"
print "Deploy to: "
stage = gets.chomp
valid_servers = %w(scraper sdk_scraper sdk_scraper_live_scan staging web darth_vader)
if !valid_servers.include?(stage)
  puts "\nInvalid input! Valid inputs are : #{valid_servers.join(' ')}\n\n"
  abort
end

# validate
branch = `git rev-parse --abbrev-ref HEAD`.chomp
print "\nDeploying branch #{branch.light_blue} to #{stage.light_cyan}. Is that correct? [yes/no]: "
res = gets.chomp
abort if !res.casecmp("yes").zero?

ENV["MS_BRANCH"] = branch

if stage == 'darth_vader'

  puts %q(


  ________            ____             __      _____ _     __   
 /_  __/ /_  ___     / __ \____ ______/ /__   / ___/(_)___/ /__ 
  / / / __ \/ _ \   / / / / __ `/ ___/ //_/   \__ \/ / __  / _ \
 / / / / / /  __/  / /_/ / /_/ / /  / ,<     ___/ / / /_/ /  __/
/_/ /_/ /_/\___/  /_____/\__,_/_/  /_/|_|   /____/_/\__,_/\___/ 
                                                                


  ).red

end

puts "\nUpdating remote references..."
begin
  `git fetch origin` # just for catching the output if it goes to stderr
rescue => e
end
puts "\nChecking that branch is in sync with remote...\n\n"
if !`git log HEAD..origin/#{branch}`.chomp.empty?
  puts "Error: origin/#{branch} is ahead of local. Pull changes".red
  abort
end

if !`git log origin/#{branch}..HEAD`.chomp.empty?
  puts "Error: local is ahead remote. Push your changes".red
  abort
end

if !`git status -uno`.include?("nothing to commit")
  puts "Error: Some local files have been edited and not committed".red
  abort
end

# run tests and abort on failure
test_cmd = 'bundle exec rake test:all'
last_line = nil
IO.popen(test_cmd).each do |line|
  puts line
  last_line = line
end.close # Without close, you won't be able to access $?
 
#puts "The command's exit code was: #{$?.exitstatus}"

last_line.split(", ")
if !(last_line.include?('0 failures') && last_line.include?('0 errors'))
  abort
end

puts ""
system("bundle exec cap #{stage} deploy")
