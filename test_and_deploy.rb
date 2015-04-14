#!/usr/bin/env ruby

current_branch = `git branch | sed -n '/\* /s///p'`.strip

if current_branch != "master"
  puts "Your current branch needs to be \"master\" to deploy."
  abort
end

git_status = `git status -uno`.strip

if ! ( git_status.include?("Your branch is up-to-date with 'origin/master'.") && git_status.include?("nothing to commit (use -u to show untracked files)") )
  puts git_status
  puts "TESTTESTTEST"
  abort
end

test_cmd = 'rake test:all'
 
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
system('cap production deploy')
