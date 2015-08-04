class EpfServiceWorker
  include Sidekiq::Worker
  
  FFS = 1.chr
  RS = 2.chr + "\n"

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
  end
  
  def save_application(record)
    # puts record
    # puts ""
    
    values = record.gsub(RS, '').split(FS)
  
    ss = IosAppEpfSnapshot.create!
    
    values.each_with_index do |value, n|
      field = field_at_index(n)
      
      s.send("#{field}=", value) if value
    end
    
    
  end
  
  def field_at_index(n)
    fields = ["export_date", "application_id", "title", "recommended_age", "artist_name", "seller_name", "company_url", "support_url", "view_url", "artwork_url_large", "artwork_url_small", "itunes_release_date", "copyright", "description", "version", "itunes_version", "download_size"][n]
  end
  
end