class SidekiqService

  class << self

    @frozen_for = 0

    def freeze_status
      "frozen for #{@frozen_for} seconds"
    end

    def on_freeze(action, interval: 1.seconds, timeout: 5.minutes)

      cur_size, last_size, size_count = 1

      # make run in background

      while cur_size > 0
        cur_size = Sidekiq::Queue.new('sdk').size
        size_count = last_size == cur_size ? size_count + 1 : 0
        last_size = cur_size
        @frozen_for = size_count
        if size_count > timeout/interval
          message = send action
          break
        end
        sleep interval
      end

    end

    private

    def reset
      data = quit
      start(data)
      notify :reset, data
    end

    def quit
      ps = Sidekiq::ProcessSet.new
      ps.select{|x| !!(x['hostname'] =~ /^scraper[1234]/) }.map do |p|
        p.stop!
        {:hostname => p['hostname'], :pid => p['pid'], :busy => p['busy'], :time => DateTime.now}
      end
    end

    def start(data)
      restart = "exec sidekiq"

      s = {
        "scraper1" => "54.88.39.109",
        "scraper2" => "54.86.80.102",
        "scraper3" => "54.210.56.58",
        "scraper4" => "54.210.55.23"
      }

      data.each do |d|
        Net::SSH.start(s[d[:hostname]], 'deploy') do |ssh|
          ssh.exec! restart
        end
      end

    end

    # def process_hash(process)
    #   process.map{|x| {:hostname => x['hostname'], :pid => x['pid'], :busy => x['busy']} }
    # end

    def notify(action, data = [{:hostname => "scraper1", :pid => 45435, :busy => 3, :time => DateTime.now},{:hostname => "scraper2", :pid => 613, :busy => 2, :time => DateTime.now},{:hostname => "scraper3", :pid => 323232, :busy => 9, :time => DateTime.now}], channel: '#slackdown', webhook: 'https://hooks.slack.com/services/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')
      notifier = Slack::Notifier.new webhook, channel: channel
      messages = data.map{|x| "#{x[:hostname]} froze at #{x[:time]}"}
      attatchments = messages.map{|x| { fallback: x, text: x, color: "#0393DD" } }
      date = DateTime.now.strftime("%l:%M%p on %B %d, %Y")
      w = attachments.count > 1 ? 'were' : 'was'
      queue = Sidekiq::Queue.new('sdk').size
      msg = "At #{date}, #{attachments.count} of 4 processes #{w} #{action} with #{queue} items in queue"
      notifier.ping msg, attachments: attachments, title: "The following processes have been #{action}"
    end

  end

end



# [{:hostname => "scraper1", :pid => 45435, :busy => 3, :time => DateTime.now},{:hostname => "scraper2", :pid => 613, :busy => 2, :time => DateTime.now},{:hostname => "scraper3", :pid => 323232, :busy => 9, :time => DateTime.now}]