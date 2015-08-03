class EpfServiceWorker
  include Sidekiq::Worker

  sidekiq_options backtrace: true, :retry => false, queue: :'172-31-32-93'

  def perform(feed_symbol_s, file)
    case feed_symbol_s.to_sym
    when :application
      perform_application(file)
    end
  end
  
  def perform_application(file)
    
    if !File.exist?(file)
      #Should only run on one server, so just chill out on the other ones
      sleep(10)
    end
    
  end
  
end