class TestBatchService
  
  DESCRIPTION = 'Batch description (this is optional)'
  
  class << self
  
    def run
      batch = Sidekiq::Batch.new
      batch.description = DESCRIPTION 
      batch.on(:complete, self)
      batch.jobs do
        5.times{ TestWorker.perform_async('hello!') }
        sleep(1)
      end
      puts "Just started Batch #{batch.bid}"
    end
  
  end
  
  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, title: 'Sidekiq Batch Completed!', description: DESCRIPTION, status: status, 'extra0' => 'hi', 'extra2' => 'bye')
  end
  
end