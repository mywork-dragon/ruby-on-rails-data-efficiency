class AndroidWrongIconTestService

  class << self
    
    def run

      batch = Sidekiq::Batch.new
      batch.description = "AndroidWrongIconTestService" 
      batch.on(:complete, 'AndroidWrongIconTestService#on_complete_run')
  
      Slackiq.message('AndroidWrongIconTestService: Queueing...', webhook_name: :main)

      batch.jobs do

        10e3.times do |n|
          AndroidWrongIconTestServiceWorker.perform_async
        end  
      
      end

      

      Slackiq.message('AndroidWrongIconTestService: Done queueing.', webhook_name: :main)

    end

  end

  def on_complete_run(status, options)
    Slackiq.notify(webhook_name: :main, status: status, title: 'AndroidWrongIconTestService Completed')
  end

end