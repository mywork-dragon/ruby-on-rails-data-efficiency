class AdHerokuTransfer

  class << self

    def add_workers(json_file)
      json = JSON.parse(IO.read(json_file))
    
      json.each do |worker_hash|
        aws_identifier = worker_hash['aws_worker_id']
        li "aws_identifier: #{aws_identifier}"
      
        worker = MTurkWorker.find_by_aws_identifier(aws_identifier)

        li "worker: #{worker}"
      
        if worker
          li "Worker #{aws_identifier} already in DB"
        else
          worker = MTurkWorker.create!(
            aws_identifier: aws_identifier,
            age: worker_hash['age'].to_i,
            gender: worker_hash['gender'],
            city: worker_hash['city'],
            state: worker_hash['state'],
            country: worker_hash['country'],
            iphone: worker_hash['iphone'],
            ios_version: worker_hash['ios_version'],
            heroku_identifier: worker_hash['heroku_id'].to_i
          )
          li "Created worker #{worker}"

        end
      
        li ""
      
      end
    
    end

    def add_ads(json_file)
      json = JSON.parse(IO.read(json_file))
    
      json.each do |ad_hash|
        
        aws_assignment_identifier = ad_hash['aws_assignment_id']
        ios_app_app_identifier = ad_hash['app_store_id']
    
        aa = FbAdAppearance.where(aws_assignment_identifier: aws_assignment_identifier, ios_app: IosApp.find_by_app_identifier(ios_app_app_identifier)).first
    
        puts "aa: #{aa}"
    
        if aa
          li "FbAdAppearance #{aa} already in DB"
        else
          aa = FbAdAppearance.new(
            aws_assignment_identifier: aws_assignment_identifier,
            hit_identifier: ad_hash['hit_id'],
            heroku_identifier: ad_hash['heroku_id'] 
          )
      
      
          aws_worker_identifier = ad_hash['aws_worker_id']
          m_turk_worker = MTurkWorker.find_by_aws_identifier(aws_worker_identifier)
          aa.m_turk_worker = m_turk_worker
      
          ios_app = IosApp.find_by_app_identifier(ios_app_app_identifier)
      
          if ios_app.nil?
        
            ios_app = IosApp.create!(app_identifier: ios_app_app_identifier) 
            app = App.create
            ios_app.app = app
            ios_app.save!
          end
      
          aa.ios_app = ios_app
      
          aa.save!
        end
      
      end
    
      nil
    end
    
    # run(ads_json_file: path_to_ads_json, workers_json_file: path_to_workers_json)
    # @author Jason Lew
    def run(options={})
      if options[:ads_json_file].nil? || options[:workers_json_file].nil?
        raise "Need keys :ads_json_file and :workers_json_file"
      end
    
      options.each do |key, value|
        raise "File #{value} does not exist" if !File.exist?(value)
      end
    
      add_workers(options[:workers_json_file])
      add_ads(options[:ads_json_file])
    end
    
    def create_csv
      CSV.open('home/deploy/fb_ads_with_data.csv', "w+") do |csv|
        columns = %w(
          title_json
          description_json
          release_notes_json
          price_json
          seller_url_json
          categories_json
          size_json
          seller_json
          developer_app_store_identifier_json
          ratings_json
          recommended_age_json
          required_ios_version_json
          support_url_html
          updated_html
          languages_html
          in_app_purchases_html
          editors_choice_html
        )
        
        csv << columns
        puts columns

        IosApp.includes(:fb_ad_appearances).where.not(fb_ad_appearances: {id: nil}).find_each do |ios_app|
           attributes = IosAppService.attributes(ios_app.app_identifier)
           puts attributes
           csv << attributes.values
        end
        
      end      
    end
    
    
  end

end