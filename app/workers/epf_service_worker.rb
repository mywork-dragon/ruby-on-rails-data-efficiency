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
       
      record += line
       
      if line.end_with?(RS)
        
        save_application(record)
        
        record = ''
        
      end
    end
    
    records
  end
  
  def save_application(record)
    puts record
    puts ""
  end
  
end