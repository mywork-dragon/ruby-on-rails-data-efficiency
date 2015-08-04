class EpfServiceWorker
  include Sidekiq::Worker
  
  FS = EpfService::FS
  RS = EpfService::RS

  sidekiq_options backtrace: true, :retry => false, queue: :'172-31-32-93'

  def perform(main_file_name, file)
    case main_file_name
    when 'application'
      perform_application(file)
    end
  end
  
  def perform_application(file)
    
    record = ''
    File.foreach(file, encoding: 'UTF-8:UTF-8').with_index do |line, line_num|
       
      if line.include?(RS)
        
        line_split = line.split(RS)
        
        record += line_split.first
          
        save_application(record)
          
        record = line_split.last
        
      else
        record += line
      end
      
    end
  end
  
  def save_application(record)
    puts record
    puts ""
    
    sleep(0.5)
  end
  
end