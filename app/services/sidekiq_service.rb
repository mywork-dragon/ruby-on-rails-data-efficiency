class SidekiqService

  class << self

    def on_freeze(action, interval: 1.seconds, timeout: 2.minutes)
      cur_size, last_size, size_count = 1
      while cur_size > 0
        cur_size = Sidekiq::Queue.new('sdk').size
        size_count = last_size == cur_size ? size_count + 1 : 0
        last_size = cur_size
        if size_count > timeout/interval
          message = send action
          break
        end
        sleep interval
      end
    end

    def reset
      quit_sidekiq
      start_sidekiq
      notify :reset
    end

    def quit_sidekiq
      run("kill $(ps -ax | grep [s]idekiq | awk '{print $1}')")
    end

    def start_sidekiq
      run("cd /home/deploy/varys_current && /usr/bin/env bundle exec sidekiq --index 0 --pidfile /home/deploy/sidekiq.pid --environment production --logfile /home/deploy/sidekiq.log --queue sdk --concurrency 50 --daemon")
    end

    private

    def notify(action, channel: '#slackdown')
      webhook = 'https://hooks.slack.com/services/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'
      notifier = Slack::Notifier.new webhook, channel: channel
      queue = Sidekiq::Queue.new('sdk').size.to_s.reverse.gsub(/...(?=.)/,'\&,').reverse
      msg = "Sidekiq was #{action} on sdk scrapers with *#{queue}* items left in queue"
      notifier.ping msg, icon_emoji: ":elephant:"
    end

    def run(command)
      ips.each do |ip|
        Net::SSH.start(ip, 'deploy', :keys => '/home/deploy/.ssh/varys-roommates') do |ssh|
          ssh.exec! command
        end
      end
    end

    def ips
      %w(54.88.39.109 54.86.80.102 54.210.56.58 54.210.55.23)
    end

  end

end
