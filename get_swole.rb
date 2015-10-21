#!/usr/bin/env ruby

swole_string = %q(

 ___  _                 _                    _                     _       _ 
|_ _|<_>._ _ _  ___   _| |_ ___   ___  ___ _| |_   ___ _ _ _  ___ | | ___ | |
 | | | || ' ' |/ ._>   | | / . \ / . |/ ._> | |   <_-<| | | |/ . \| |/ ._>|_/
 |_| |_||_|_|_|\___.   |_| \___/ \_. |\___. |_|   /__/|__/_/ \___/|_|\___.<_>
                                 <___'

)                                       

puts swole_string

puts "\nWhich servers would you like to deploy to?\n\n"
puts "Options"
puts "-------"
puts "scraper: Deploys to the main scraper servers."
puts "sdk_scraper: Deploys to the SDK scraper servers."
puts "sdk_scraper_live_scan: Deploys to the SDK scraper live scan."
puts "staging: Deploys to the staging server."
puts "web: Deploys to the Web server."
puts "\n"
print "Deploy to: "
stage = gets.chomp
valid_servers = %w(scraper sdk_scraper sdk_scraper_live_scan staging web)
if !valid_servers.include?(stage)
  puts "\nInvalid input! Valid inputs are : #{valid_servers.join(' ')}\n\n"
  abort
end

# validate
branch = `git rev-parse --abbrev-ref HEAD`.chomp
puts "Deploying branch #{branch} to #{stage}. Is that correct? [yes/no]"
res = gets.chomp
abort if !res.casecmp("yes").zero?

ENV["MS_BRANCH"] = branch

# check that branch is up to date with remote
git_status = `git status -uno`.strip
if ! ( git_status.include?("Your branch is up-to-date") && git_status.include?("nothing to commit (use -u to show untracked files)") )
  puts git_status
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
