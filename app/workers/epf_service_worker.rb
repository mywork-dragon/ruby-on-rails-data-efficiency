class EpfServiceWorker
  include Sidekiq::Worker
  
  FS = 1.chr
  RS = 2.chr + "\n"

  sidekiq_options backtrace: true, :retry => false, queue: :scraper_master

  def perform(epf_full_feed_id, main_file_name, file)
    case main_file_name
    when 'application'
      perform_application(epf_full_feed_id, file)
    end
  end
  
  def perform_application(epf_full_feed_id, file)
    
    record = ''
    File.foreach(file, encoding: 'UTF-8:UTF-8').with_index do |line, line_num|
       
      record += line
       
      if line.end_with?(RS)
        
        save_application(epf_full_feed_id, record)
        
        record = ''
        
      end
    end
  end
  
  def save_application(epf_full_feed_id, record)
    # puts record
    # puts ""
    
    values = record.gsub(RS, '').split(FS)
  
    return false unless IosAppEpfSnapshot.where(epf_full_feed_id: epf_full_feed_id, application_id: values[1]).blank?
  
    ss = IosAppEpfSnapshot.new
    
    values.each_with_index do |value, n|
      field = field_at_index(n)
      
      ss.send("#{field}=", value) if value
    end
    
    ss.save
    
    
  end
  
  def field_at_index(n)
    fields = ["export_date", "application_id", "title", "recommended_age", "artist_name", "seller_name", "company_url", "support_url", "view_url", "artwork_url_large", "artwork_url_small", "itunes_release_date", "copyright", "description", "version", "itunes_version", "download_size"][n]
  end
  
end