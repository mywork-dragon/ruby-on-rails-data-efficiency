class SidekiqTesterService
  class << self

    def do_stuff
      batch = Sidekiq::Batch.new
      batch.description = 'sup'
      batch.on(:complete, 'SidekiqTesterService#on_complete')

      batch.jobs do
        100.times do
          SidekiqTesterServiceWorker.perform_async
        end
      end
    end
  end

  def on_complete(status, options)
    sleep 10
    Slackiq.notify(webhook_name: :main, status: status, title: 'testing sidekiq gem')
  end
  
end