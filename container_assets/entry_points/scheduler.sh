#!/bin/bash

function shutdown_scheduler {
  # cleanup here.
  bundle exec rails runner  'Slackiq.message("scheduler shutting down", webhook_name: :main)'

  # Ask ruby processes to terminate.
  pkill ruby
  # Wait until the processes stop.
  procs=$(pgrep ruby)
  while [ ! -z "$procs" ]; do
    procs=$(pgrep ruby)
    sleep 1
  done

  exit
}

# Catch these signals and cleanup/shutdown.
trap shutdown_scheduler SIGHUP SIGINT SIGTERM

# Write crontab from schedule.rb for the varys_scheduler role.
bundle exec whenever --roles varys_scheduler --update-crontab

# Write env to /etc/env (allows cron jobs to access env).
env >> /etc/environment

# Start cron in the background.
cron

bundle exec rails runner  'Slackiq.message("scheduler started", webhook_name: :main)'

touch /var/log/cron.log

# Write cron logs to stdout.
tail -f /var/log/cron.log
