#!/usr/bin/env ruby

begin
  require 'colorize'
rescue => e
  puts "\nYou need to install the colorize gem to get swole."
  puts "gem install colorize"
  abort
end

begin
  require 'json'
rescue => e
  puts "\nYou need to install the json gem to get swole."
  puts "gem install json"
  abort
end

arg0 = ARGV[0]
ARGV.clear

run_tests = true

if arg0
  if arg0 == '--skip-tests'
    run_tests = false
  else
    puts "Illegal argument.".red
    abort
  end
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
puts "sdk_scraper_live_scan".light_cyan + ": Deploys to the SDK scraper live scan (Android)."
puts "staging:".light_cyan + " Deploys to the staging server."
puts "web".light_cyan + ": Deploys to the Web server."
puts "darth_vader".light_cyan + ": Deploys to Vader (iOS Live Scan)."
puts "kylo_ren".light_cyan + ": Deploys to Kylo Ren (iOS Mass Scan and Dev)."
puts "ios_live_scan".light_cyan + ": Deploys to the iOS live scan."
puts "\n"
print "Deploy to: "
stage = gets.chomp
valid_servers = %w(scraper sdk_scraper sdk_scraper_live_scan staging web darth_vader kylo_ren ios_live_scan)
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

if stage == 'darth_vader' || stage == 'kylo_ren'

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

if run_tests
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

elsif %w(web sdk_scraper_live_scan darth_vader ios_live_scan).include?(stage)
  puts "Stage #{stage} is a live production stage. You're not allowed to bypass tests for this stage.".red
  abort
end

puts ""
system("bundle exec cap #{stage} deploy")

# Post deployment to Slack
url = 'https://hooks.slack.com/services/T02T20A54/B0KTNR7RT/O2jPFin7ZGstDJSvJCPFyn9'  # the webhook for the deployment channel
user = `echo $USER`
title = "`#{user}` deployed `#{branch}` to `#{stage}`."

fields =  [
            {
              'title' => 'Who',
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
            }
          ]

attachments = [
                {
                  'fallback' => title,

                  'color' => '#00ff66',

                  'title' => title,

                  # 'text' => description,

                  'fields' => fields,
                }
              ]

body = {attachments: attachments}.to_json

uri = URI(url)
req = Net::HTTP::Post.new(uri, initheader = {'Content-Type' =>'application/json'})
req.body = body
res = Net::HTTP.start(uri.hostname, uri.port) do |http|
  http.request(req)
end