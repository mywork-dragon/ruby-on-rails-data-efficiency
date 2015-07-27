class TestBatchService
  
  class << self
  
    def run
      batch = Sidekiq::Batch.new
      description = 'Batch description (this is optional)'
      batch.description = description 
      batch.on(:complete, self, description: description)
      batch.jobs do
        TestWorker.perform_async('hello!')
      end
      puts "Just started Batch #{batch.bid}"
    end
  
  end
  
  def on_complete(status, options)
    puts "status.created_at.class #{status.created_at.class}"
    Slackiq.notify(webhook_name: :main, description: options[:description], status: status, 'extra0' => 'hi', 'extra2' => 'bye')
  end
  
end