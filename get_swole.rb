#!/usr/bin/env ruby

gems = %w(colorize json net/http)

gems.each do |gem_name|
  begin
    require gem_name
  rescue => e
    puts "\nYou need to install the #{gem_name} gem to get swole."
    puts "gem install #{gem_name}"
    abort
  end
end

unless File.exist?(File.join(ENV['HOME'], '.ssh', 'varys'))
  puts "Ensure you have the varys key in your .ssh directory".red
  abort
end

swole_string = %q(

 ___  _                 _                     _                     _       _ 
|_ _|<_>._ _ _  ___   _| |_ ___    ___  ___ _| |_   ___ _ _ _  ___ | | ___ | |
 | | | || ' ' |/ ._>   | | / . \  / . |/ ._> | |   <_-<| | | |/ . \| |/ ._>|_/
 |_| |_||_|_|_|\___.   |_| \___/  \_. |\___. |_|   /__/|__/_/ \___/|_|\___.<_>
                                  <___'

)                                       

puts swole_string.light_yellow

puts "\nWhich servers would you like to deploy to?\n\n"
puts "Options"
puts "-------"
puts "darth_vader".light_cyan + ": Deploys to Vader (iOS Live Scan)."
puts "kylo_ren".light_cyan + ": Deploys to Kylo Ren (iOS Mass Scan and Ad Spend)."
puts "darth_maul".light_cyan + ": Deploys to Darth Maul (Dev)."
puts "\n"
print "Deploy to: "
stage = gets.chomp
valid_servers = %w(darth_vader kylo_ren darth_maul)
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

if %w(darth_vader kylo_ren darth_maul).include?(stage)

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

# collect attributes now for later Slack notification
user = `echo $USER`.chomp
url = 'https://hooks.slack.com/services/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'  # the webhook for the deployment channel
commit_hash = `git rev-parse --verify HEAD`.chomp
author = `git --no-pager show -s --format='%an' #{commit_hash}`.chomp
commit_message = `git show -s --format=%B #{commit_hash}`.chomp
title = "#{user} deployed #{branch} to #{stage}.".chomp

puts ''
puts 'Checking syntax with rubocop'.light_yellow
res = system('rubocop', out: $stdout, err: :out)
if res != true
  puts 'Rubocop check failed. Fix the errors before deploying'.red
  abort
end

# run tests and abort on failure
puts ''
puts 'Running rake tests'.light_yellow
test_cmd = 'bundle exec rake test'
last_line = nil
second_last_line = nil
IO.popen(test_cmd).each do |line|
  puts line
  second_last_line = last_line
  last_line = line
end.close # Without close, you won't be able to access $?
 
second_last_line.split(", ")
if !(second_last_line.include?('0 failures') && second_last_line.include?('0 errors'))
  abort
end

puts ""
puts "Stage: #{stage}"
system("bundle exec cap #{stage} deploy")

# Post deployment to Slack

fields =  [
            {
              'title' => 'User',
              'value' => user,
              'short' => true
            },
            {
              'title' => 'Branch',
              'value' => branch,
              'short' => true
            },
            {
              'title' => 'Stage',
              'value' => stage,
              'short' => true
            },
            {
              'title' => 'Commit Author',
              'value' => author,
              'short' => true
            },
            {
              'title' => 'Commit Hash',
              'value' => "<https://github.com/MightySignal/varys/commit/#{commit_hash}|#{commit_hash}>",
              'short' => true
            },
            {
              'title' => 'Commit Message',
              'value' => commit_message,
              'short' => true
            }
          ]

attachments = [
                {
                  'fallback' => title,

                  'color' => '#6600FF',

                  'title' => title,

                  'fields' => fields,

                  'mrkdwn_in' => ['fields']
                }
              ]

body = {attachments: attachments}.to_json

uri = URI(url)
req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
req.body = body
res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
  http.request(req)
end

puts ""
puts "Deployment to " + stage.light_cyan + " is complete."
