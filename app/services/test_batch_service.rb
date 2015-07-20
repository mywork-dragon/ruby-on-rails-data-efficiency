class TestBatchService
  
  class << self
  
    def run
      batch = Sidekiq::Batch.new
      batch.description = "Batch description (this is optional)"
      batch.on(:complete, 'SlackNotificationService#done')
      batch.jobs do
        TestWorker.perform_async('hello!')
      end
      puts "Just started Batch #{batch.bid}"
    end
  
  end
  
end