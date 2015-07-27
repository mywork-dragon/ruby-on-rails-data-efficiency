class TestBatchService
  
  class << self
  
    def run
      batch = Sidekiq::Batch.new
      description = 'Batch description (this is optional)'
      batch.description = description 
      batch.on(:complete, self, description: description.dup)
      batch.jobs do
        5.times{ TestWorker.perform_async('hello!') }
      end
      puts "Just started Batch #{batch.bid}"
    end
  
  end
  
  def on_complete(status, options)
    puts "description: #{options[:description]}"
    Slackiq.notify(webhook_name: :main, description: options[:description], status: status, 'extra0' => 'hi', 'extra2' => 'bye')
  end
  
end