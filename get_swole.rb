#!/usr/bin/env ruby

swole_string = %q(

 ___  _                 _                    _                     _       _ 
|_ _|<_>._ _ _  ___   _| |_ ___   ___  ___ _| |_   ___ _ _ _  ___ | | ___ | |
 | | | || ' ' |/ ._>   | | / . \ / . |/ ._> | |   <_-<| | | |/ . \| |/ ._>|_/
 |_| |_||_|_|_|\___.   |_| \___/ \_. |\___. |_|   /__/|__/_/ \___/|_|\___.<_>
                                 <___'

)                                       

puts swole_string

current_branch = `git branch | sed -n '/\* /s///p'`.strip

if current_branch != "master"
  puts "Your current branch needs to be \"master\" to deploy."
  abort
end

git_status = `git status -uno`.strip

if ! ( git_status.include?("Your branch is up-to-date with 'origin/master'.") && git_status.include?("nothing to commit (use -u to show untracked files)") )
  puts git_status
  abort
end



puts "\nWhich servers would you like to deploy to?\n\n"
puts "Options"
puts "-------"
puts "scraper: Deploys to the main scraper servers. Branch is 'scraper'"
puts "sdk_scraper: Deploys to the SDK scraper servers. Branch is 'scraper'"
puts "web_api: Deploys to the Web and API servers. Branch is 'master'"
puts "all: Deploys to all servers. Branch is 'master'" 
puts "\n\n"
print "Deploy to: "
stage = gets
stages = %w(scraper sdk_scraper web_api all)
if !stages.include?(stage)
  puts "Valid inputs: #{stages.join(' ')}"
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

if `animate --version`.include?('command not found')
  puts "\n\n\n\nYou must run `sudo port install ImageMagick` before you can get swole."
  exit
end

system('animate bicep_curl.gif &')

puts ""
system('bundle exec cap production deploy')
