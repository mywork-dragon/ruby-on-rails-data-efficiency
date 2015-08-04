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
    
    File.foreach(filename).with_index do |line, line_num|
       puts "#{line_num}: #{line}"
       
       
    end
  end
  
end