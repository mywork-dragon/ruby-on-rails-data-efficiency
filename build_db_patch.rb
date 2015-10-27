#!/usr/bin/env ruby
require 'json'
begin
	require 'colorize'
rescue => e
	puts "\nYou need to install the colorize gem."
	puts "gem install colorize"
	abort
end

outfile = "db.patch"
db_files = %w{db app/models test/models test/fixtures}

# update remote references
puts "Updating remote references".light_blue
`git fetch origin`

current_branch = `git rev-parse --abbrev-ref HEAD`.chomp

puts "Checking that branch is in sync with remote".light_blue
if !`git log HEAD..origin/#{current_branch}`.chomp.empty?
  puts "Error: origin/#{current_branch} is ahead of local. Pull changes".red
  abort
end

if !`git log origin/#{current_branch}..HEAD`.chomp.empty?
  puts "Error: local is ahead remote. Push your changes".red
  abort
end

if !`git status -uno`.include?("nothing to commit")
  puts "Error: Some local files have been edited and not committed".red
  abort
end

puts "Making sure that branch is ahead of origin/master".light_blue
if `git rev-list --left-right --count origin/master...#{current_branch} | cut -f 1`.chomp != "0"
	puts "Error: local branch is ahead of remote master. Pull master into your branch to merge and catch up".red
	abort
end

# make sure there are changes
puts "Checking for db related changes".light_blue
names = `git diff --name-only origin/master #{db_files.join(' ')}`.chomp.split('\n')

if names.empty?
	puts "No db changes detected. Nothing to do".light_blue
	abort
end

# create patch
`git diff origin/master #{db_files.join(' ')} > #{outfile}`

puts "Patch with db changes created at #{outfile}".light_blue


print "Create and push new branch with changes to merge into master? [yes/no]: ".yellow
res = gets.chomp
if !res.casecmp("yes").zero?
	puts "SUCCESS".green
	puts "Apply the patch at #{outfile} to a feature branch off master".light_blue
	abort
end

puts "Preparing to create new branch".light_blue

# http://stackoverflow.com/questions/18134627/how-much-of-a-git-sha-is-generally-considered-necessary-to-uniquely-identify-a
unique_hash = `git rev-parse HEAD | cut -b 1-12`.chomp
new_branch_name = "#{unique_hash}_#{current_branch}_to_master"

# check if sha hash exists in branch name. If it does, then this branch has already been created
collisions = `git branch -a | grep #{unique_hash}`.chomp.split('\n')

if !collisions.empty?
	puts "Error: a patch to master have already been created for this hash".red
	puts collisions.join('\n').red
	abort
end

puts "Creating new branch #{new_branch_name} off master".light_blue

`git checkout master`
`git pull origin master`
`git checkout -b #{new_branch_name}`

puts "******** NEW BRANCH CREATED **********".light_blue
puts "#{new_branch_name}".green
puts "**************************************".light_blue

puts "Applying db patch to the branch".light_blue

res = `git apply #{outfile}`.chomp
if res.include?("patch failed")
	puts "Error: Cannot apply patch because of conflicts. Check to see if someone committed and pushed in the last 30 seconds".red
	puts "Branch has not been pushed to remote. To delete, call git branch -D #{new_branch_name}".red
	abort
end

puts "Committing files".light_blue

`git add #{db_files.join(' ')}`
`git commit -m 'Adding migrations files from branch #{current_branch} via script'`

puts "Pushing branch on remote".light_blue

`git push origin #{new_branch_name}`

print "Create the pull request in Github? [yes/no]: ".yellow
res = gets.chomp

if !res.casecmp("yes").zero?
	# go back to current state
	`git checkout #{current_branch}`
	puts "SUCCESS".green
	puts "Remote branch #{new_branch_name} created. Create a pull request to get it reviewed and then merge into master".light_blue
	abort
end

puts "Getting user Github API token".light_blue
res = `[ -f config/.github_token ] && echo "exists" || echo "dne"`.chomp
if res != "exists"
	puts "Error: Add a personal access token to /path/to/varys/config/.github_token".red
	abort
end

puts "Getting user information".light_blue
name = `git config user.name`.chomp
print "Enter your get user name [press enter to use default - #{name}]: ".yellow
res = gets.chomp
name = res if !res.empty?

token = File.open('./config/.github_token', 'rb') { |f| f.read }
token = token.chomp

puts "Building pull request information".light_blue
data = {
	title: "Merging database changes from #{current_branch} to master via script",
	body: "Changes are in files:\n#{names.join('\n')}",
	head: "#{new_branch_name}",
	base: "master"
}

puts "Creating pull request via Github"

res = JSON.parse(`curl -X POST -s -u '#{name}':#{token} https://api.github.com/repos/MightySignal/varys/pulls -d '#{data.to_json}'`)

if !res.has_key?('html_url')
	puts "Error: Could not create pull request. Request failed with: ".red
	puts JSON.pretty_generate(res).red
	abort
end

puts "******** PULL REQUEST CREATED **********".light_blue
puts "Follow the link below to view it"
puts "#{res['html_url']}".green
puts "**************************************".light_blue

`git checkout #{current_branch}`
puts "SUCCESS".green