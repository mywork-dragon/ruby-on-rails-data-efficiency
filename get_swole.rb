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
puts "Options: web_api scraper sdk_scraper all\n\n"
print "Deploy to: "
stage = gets
puts stage 
abort

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
