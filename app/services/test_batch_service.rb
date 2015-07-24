class TestBatchService
  
  class << self
  
    def run
      batch = Sidekiq::Batch.new
      description = 'Batch description (this is optional)'
      batch.description = description 
      batch.on(:complete, 'SlackNotificationService#done')
      batch.on(:complete, self, description: description)
      batch.jobs do
        TestWorker.perform_async('hello!')
      end
      puts "Just started Batch #{batch.bid}"
    end
  
    def on_complete(status, options)
      Slackiq.notify(:main, options[:description], status, 'extra0' => 'hi', 'extra2' => 'bye')
    end
  
  end
  
end