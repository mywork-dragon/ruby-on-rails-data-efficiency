class BusinessEntityAndroidServiceWorker
  include Sidekiq::Worker
  #
  # def perform(android_snapshot_ids)
  #   android_snapshot_ids.each do |android_snapshot_id|
  #     ss = AndroidAppSnapshot.find(android_snapshot_id)
  #
  #     return if ss.nil?
  #
  #     url = ss.seller_url
  #
  #     if url_is_social?(url)
  #       kind = :social
  #     else
  #       url = UrlHelper.url_with_http_and_domain(url)
  #       kind = :primary
  #     end
  #
  #     w = Website.find_by_url(url)
  #
  #     if w.nil?
  #
  #       c = Company.find_by_google_play_identifier
  #
  #   end
  # end
  #
  # def perform(ios_app_snapshot_ids)
  #
  #   ios_app_snapshot_ids.each do |ios_app_snapshot_id|
  #
  #     ss = IosAppSnapshot.find(ios_app_snapshot_id)
  #
  #     return if ss.nil?
  #
  #     urls = [ss.seller_url, ss.support_url].select{|url| url}
  #
  #     urls.each do |url|
  #       if url_is_social?(url)
  #         kind = :social
  #       else
  #         url = UrlHelper.url_with_http_and_domain(url)
  #         kind = :primary
  #       end
  #
  #       w = Website.find_by_url(url)
  #
  #       if w.nil?
  #         c = Company.find_by_app_store_identifier(ss.developer_app_store_identifier)
  #         c = Company.create(name: I18n.transliterate(ss.seller), app_store_identifier: ss.developer_app_store_identifier) if c.nil?
  #         w = Website.create(url: url, company: c, kind: kind)
  #       elsif w.company.nil?
  #         w.company = Company.create(name: I18n.transliterate(ss.seller), app_store_identifier: ss.developer_app_store_identifier)
  #         w.save
  #       end
  #
  #       ios_app = ss.ios_app
  #
  #       ios_app.websites << w if !ios_app.websites.include?(w)
  #       ios_app.save
  #
  #     end
  #
  #   end
  #
  # end
  
end