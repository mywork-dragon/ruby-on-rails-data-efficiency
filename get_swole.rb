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
puts "scraper: Deploys to the main scraper servers. Branch is 'scraper'"
puts "sdk_scraper: Deploys to the SDK scraper servers. Branch is 'sdk_scraper'"
puts "web: Deploys to the Web server. Branch is 'master'"
puts "all: Deploys to all servers. Branch is 'master'" 
puts "\n"
print "Deploy to: "
servers = gets.chomp
valid_servers = %w(scraper sdk_scraper web all)
if !valid_servers.include?(servers)
  puts "\nInvalid input! Valid inputs are : #{valid_servers.join(' ')}\n\n"
  abort
end

if servers == 'scraper'
  branch = 'scraper'
  stage = branch
elsif servers == 'sdk_scraper'
  branch = 'sdk_scraper'
  stage = branch
elsif servers == 'web'
  branch = 'master'
  stage = 'web'
elsif servers == 'all'
  branch = 'master'
  stage = 'production'
end

current_branch = `git branch | sed -n '/\* /s///p'`.strip

if current_branch != branch
  puts "Your current branch needs to be \"#{branch}\" to deploy."
  abort
end

git_status = `git status -uno`.strip

if ! ( git_status.include?("Your branch is up-to-date with 'origin/#{branch}'.") && git_status.include?("nothing to commit (use -u to show untracked files)") )
  puts git_status
  abort
end

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
