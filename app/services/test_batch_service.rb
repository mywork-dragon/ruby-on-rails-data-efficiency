class TestBatchService
  
  class << self
  
    def run
      batch = Sidekiq::Batch.new
      batch.description = 'Batch description (this is optional)' 
      # batch.on(:complete, self)
      
      Slackiq.notify_on(:complete, batch) do |status|
        {webhook_name: :main, title: 'NEW TITLE', 'This' => 'Is', 'A' => 'Test'}
      end
      
      batch.jobs do
        5.times{ TestWorker.perform_async('hello!') }
        sleep(1)
      end
      puts "Just started Batch #{batch.bid}"
    end
  
  end
  
  def on_complete(status, options)
    Slackiq.notify(webhook_name: :main, title: 'Sidekiq Batch Completed!', status: status, 'extra0' => 'hi', 'extra2' => 'bye')
  end
  
end