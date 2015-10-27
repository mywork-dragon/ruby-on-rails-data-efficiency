class CustomCsvService

  class << self

    def export_list_to_csv(file_path)

      can_view_support_desk = false

      CSV.open(file_path, "w") do |csv|

        header = ['MightySignal App ID', 'App Name', 'App Type', 'Mobile Priority', 'User Base', 'Last Updated', 'Ad Spend', 'Categories', 'MightySignal Company ID', 'Company Name', 'Fortune Rank', 'Company Website(s)', 'MightySignal App Page', 'MightySignal Company Page']
        can_view_support_desk ? header.push('Support URL') : nil

        csv << header

        IosApp.where(user_base: [IosApp.user_bases[:elite], IosApp.user_bases[:strong]]).find_each.with_index do |app, index|
          puts "iOS app #{index}"

          company = app.get_company
          newest_snapshot = app.newest_ios_app_snapshot

          app_hash = [
            app.id,
            newest_snapshot.present? ? newest_snapshot.name : nil,
            'IosApp',
            app.mobile_priority,
            app.user_base,
            newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
            app.ios_fb_ad_appearances.present?,
            newest_snapshot.present? ? IosAppCategoriesSnapshot.where(ios_app_snapshot: newest_snapshot, kind: IosAppCategoriesSnapshot.kinds[:primary]).map{|iacs| iacs.ios_app_category.name}.join(", ") : nil,
            company.present? ? company.id : nil,
            company.present? ? company.name : nil,
            company.present? ? company.fortune_1000_rank : nil,
            app.get_website_urls.join(", "),
            'http://www.mightysignal.com/app/app#/app/ios/' + app.id.to_s,
            company.present? ? 'http://www.mightysignal.com/app/app#/company/' + company.id.to_s : nil,
            can_view_support_desk && newest_snapshot.present? ? newest_snapshot.support_url : nil
          ]

          csv << app_hash
        end

        AndroidApp.where(user_base: [AndroidApp.user_bases[:elite], AndroidApp.user_bases[:strong]]).find_each.with_index do |app, index|
          puts "Android app #{index}"

          company = app.get_company
          newest_snapshot = app.newest_android_app_snapshot

          app_hash = [
            app.id,
            newest_snapshot.present? ? newest_snapshot.name : nil,
            'AndroidApp',
            app.mobile_priority,
            app.user_base,
            newest_snapshot.present? ? newest_snapshot.released.to_s : nil,
            app.android_fb_ad_appearances.present?,
            newest_snapshot.present? ? newest_snapshot.android_app_categories.map{|c| c.name}.join(", ") : nil,
            company.present? ? company.id : nil,
            company.present? ? company.name : nil,
            company.present? ? company.fortune_1000_rank : nil,
            app.get_website_urls.join(", "),
            'http://www.mightysignal.com/app/app#/app/android/' + app.id.to_s,
            company.present? ? 'http://www.mightysignal.com/app/app#/company/' + company.id.to_s : nil
          ]

          csv << app_hash

        end 

      end

    end

  end

end