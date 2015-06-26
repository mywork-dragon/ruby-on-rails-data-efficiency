class BusinessEntityAndroidServiceWorker
  include Sidekiq::Worker
  
  sidekiq_options retry: false
 
  def perform(ids)
    # m = method_name.to_sym
    # send(m, ids)
    check_for_existence(ids)
  end

  MAX_TRIES = 3

  def check_for_existence(ids)
    ids.each do |android_app_id|

      try = 0

      aa = AndroidApp.find_by_id(android_app_id)
      next if aa.nil?

      url = "https://play.google.com/store/apps/details?id=#{aa.app_identifier}"

      begin
        Tor.get(url)
      rescue => e
        if e.message.include? '404'
          # App was not found.
          aa.taken_down = true
          aa.save
        else
          retry if (try += 1) < MAX_TRIES
        end
      else
        # App was found.
        next
      end

    end
  end

  def dupe_count(ids)
    ids.each do |android_app_id|
      aa = AndroidApp.find_by_id(android_app_id)
      next if aa.nil?

      dupe = Dupe.find_by_app_identifier(aa.app_identifier)
      
      if dupe.nil?
        Dupe.create(app_identifier: aa.app_identifier, count: 1)
      else
        dupe.count += 1
        dupe.save
      end
    end
  end

  def associate_newest_snapshot_android(android_app_ids)
    android_app_ids.each do |android_app_id|
      aa = AndroidApp.find(android_app_id)
      return if aa.nil?
      newest_snapshot = aa.android_app_snapshots.select{|ss| ss.name.present?}.max_by{|ss| ss.android_app_snapshot_job_id}
      if newest_snapshot.present?
        aa.newest_android_app_snapshot = newest_snapshot
        aa.save
      end
    end
  end

  def delete_dupes_android(dupe_ids)
    dupe_ids.each do |dupe_id|
      dupe = Dupe.find_by_id(dupe_id)
      next if dupe.nil?
      
      app_identifier = dupe.app_identifier
      aa = AndroidApp.where(app_identifier: app_identifier)
      if aa.count > 1
        keep = aa.max_by{ |a| a.created_at }
        aa.each do |a|
          if a.id != keep.id
            AndroidApp.delete(a.id)
          end
        end
      end
    end
  end

  def delete_duplicates_android(android_app_ids)
    android_app_ids.each do |android_app_id|
      aa = AndroidApp.find_by_id(android_app_id)
      return if aa.nil?
      aa_id = AndroidApp.where(app_identifier: aa.app_identifier)

      if aa_id.count > 1
        keep = aa_id.max_by{ |a| a.created_at }
        aa_id.each do |a|
          if a.id != keep.id
            AndroidApp.delete(a.id)
          end
        end
      end

    end
  end

  def unlink_android_without_dev_id(android_app_ids)

    android_app_ids.each do |android_app_id|
      
      aa = AndroidApp.find_by_id(android_app_id)
      next if aa.nil?
      
      ss = AndroidAppSnapshot.where(android_app_id: aa.id).order(created_at: :desc).first
      next if ss.blank?

      urls = aa.websites.map{ |site| site.url }
      
      urls = urls.map{ |url| UrlHelper.url_with_http_and_domain(url) }.select{ |url| url.present? }
      
      urls.each do |url|

        next if url.blank?

        known_dev_id = UrlHelper.known_website_android(url) 

        ss_dasi = ss.developer_google_play_identifier

        website = Website.find_or_create_by(url: url)
        
        if ss_dasi.blank? && known_dev_id.present?
          unlink_android_and_web(android_app: android_app, website: website)
        end
      end
    end
  end

  def clean_android(android_app_snapshot_ids)

    android_app_snapshot_ids.each do |android_app_snapshot_id|
    
      ss = AndroidAppSnapshot.find_by_id(android_app_snapshot_id)
      return if ss.nil?
      
      android_app = ss.android_app

      urls = ss.android_app.websites.map{ |site| site.url }
      
      urls = urls.map{|url| UrlHelper.url_with_http_and_domain(url)}
      
      urls.each do |url|

        next if url.nil?

        known_dev_id = UrlHelper.known_website_android(url) 

        puts known_dev_id

        ss_dasi = ss.developer_google_play_identifier
        
        next if ss_dasi.blank?
        
        company = Company.find_by_google_play_identifier(ss_dasi)

        website = Website.find_or_create_by(url: url)

        f1000 = website.company.present? && website.company.fortune_1000_rank.present?

        if known_dev_id.present?
          if ss_dasi == known_dev_id
            websites_to_remove = android_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            android_app.websites.delete(websites_to_remove)
            link_co_and_web(website: website, company: company)
            link_android_and_web(android_app: android_app, website: website)
          else
            unlink_android_and_web(android_app: android_app, website: website)
          end
        else
          if website.company.present? && website.company.google_play_identifier.present? && website.company.google_play_identifier != ss_dasi && !f1000
            unlink_android_and_web(android_app: android_app, website: website)
          end
        
          if company.present?
            websites_to_remove = android_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            android_app.websites.delete(websites_to_remove)

            link_co_and_web(website: website, company: company)
            link_android_and_web(android_app: android_app, website: website)
          end
        
          if website.company.blank?
            websites_to_remove = android_app.websites.to_a.select{|site| urls.exclude?(site.url)}
            android_app.websites.delete(websites_to_remove)
            new_co = Company.create(name: ss.seller, google_play_identifier: ss_dasi)
            link_co_and_web(website: website, company: new_co)
            link_android_and_web(android_app: android_app, website: website)
          end

        end
      end
      
      websites = android_app.websites.select{|w| urls.exclude?(w.url)}
      websites.each do |website|
        known_dev_id = UrlHelper.known_website(website.url)
        ss_dasi = ss.developer_google_play_identifier
        company = website.company
        
        known_dev_dasi_mismatch = known_dev_id.present? && ss_dasi != known_dev_id
        company_dasi_mismatch = company.present? && company.google_play_identifier.present? && company.google_play_identifier != ss_dasi
        if known_dev_dasi_mismatch || company_dasi_mismatch
          unlink_android_and_web(android_app: android_app, website: website)
        end
      end
      
      
    end
  end

  def link_android_and_web(android_app:, website:)
    if !android_app.websites.include?(website)
      android_app.websites << website
    end
  end

  def unlink_android_and_web(android_app:, website:)
    if android_app.websites.include?(website)
      android_app.websites.delete(website)
    end
  end

  def link_co_and_web(website:, company:)
    website.company = company
    website.save
  end

  
end







   # android_snapshot_ids.each do |android_snapshot_id|
   #    ss = AndroidAppSnapshot.find(android_snapshot_id)
   #    android_app = ss.android_app

   #    return if ss.nil?

   #    if dgpi = ss.developer_google_play_identifier
   #      c = Company.find_by_google_play_identifier(dgpi)

   #      if c && !c.websites.empty?
   #        primary_website = c.websites.first
        
   #        if !android_app.websites.include?(primary_website)
   #          android_app.websites << primary_website 
   #          android_app.save
   #        end
        
   #        next  #go to the next app
   #      end
   #    end

   #    #start looking at url if identifier didn't match

   #    url = ss.seller_url

   #    next if url.blank?

   #    if UrlHelper.secondary_site?(url)
   #      kind = :secondary
   #    else
   #      url = UrlHelper.url_with_http_and_domain(url)
   #      kind = :primary
   #    end

   #    w = Website.find_by_url(url)

   #    if w.nil?
   #      c = Company.find_by_google_play_identifier(ss.developer_google_play_identifier)
   #      c = Company.create(name: ss.seller, google_play_identifier: ss.developer_google_play_identifier) if c.nil?
   #      w = Website.create(url: url, company: c, kind: kind)
   #    elsif w.company.nil?
   #      c = Company.create(name: ss.seller, google_play_identifier: ss.developer_google_play_identifier)
   #      w.company = c
   #      w.save
   #    elsif !w.company.google_play_identifier.blank?  
   #      next
   #    end

   #    android_app.websites << w unless android_app.websites.include?(w)
   #    android_app.save

   #  end