class MachineLearningService

  def sample_algo
    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new

    parameter.cache_size = 1 # in megabytes

    parameter.eps = 0.001
    parameter.c = 10

    examples = [ [0, 0, 0, 0], [1, 0, 0, 0], [1, 1, 1, 1], [1, 0, 1, 1] ].map {|ary| Libsvm::Node.features(ary) }
    
    #labels
    # 0: link to no company
    # 1: link to existing company with developer identifier 
    # 2: link to seller_url
    # 3: link to support_url
    
    labels = [0, 1, 1, 1]

    problem.set_examples(labels, examples)

    model = Libsvm::Model.train(problem, parameter)

    # pred = model.predict(Libsvm::Node.features(1, 1, 1))
    pred = model.predict(Libsvm::Node.features(1, 0, 1, 0))
    puts "Predicted #{pred}"
  end
  
  def predict
    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new

    parameter.cache_size = 1 # in megabytes

    parameter.eps = 0.001
    parameter.c = 10
    
    training_ss_ids = [2909093]
    
    training_ss_ids.map do |id|
      ss = IosAppSnapshot.find(id)
      
      appearances = IosAppSnapshot.where(ios_app_snapshot_job_id: ss.ios_app_snapshot_job_id, seller_url: ss.seller_url, developer_app_store_identifier: ss.developer_app_store_identifier).count
      total = IosAppSnapshot.where(ios_app_snapshot_job_id: ss.ios_app_snapshot_job_id, developer_app_store_identifier: ss.developer_app_store_identifier).count
      percentage_other_apps_same_website = (appearances.to_f)/(total.to_f)
      
      contact_support_link_same = UrlHelper.url_with_domain_only(ss.seller_url) == UrlHelper.url_with_domain_only(ss.support_url) ? 1 : 0
      
      reviews = ss.ratings_all_count/5.0e6
      
      white = Text::WhiteSimilarity.new
      company_name_in_domain_percentage = white.similarity(ss.seller, UrlHelper.url_with_domain_only(ss.seller_url))
      create_vector(company_name_in_domain_percentage: company_name_in_domain_percentage)
      
      create_vector(percentage_other_apps_same_website: percentage_other_apps_same_website, reviews: reviews, contact_support_link_same: contact_support_link_same, company_name_in_domain_percentage: company_name_in_domain_percentage)
    end
    
  end

  
  #scale reviews down by 5M
  
  def create_vector(percentage_other_apps_same_website:, reviews:, contact_support_link_same:, company_name_in_domain_percentage:)
    [percentage_other_apps_same_website, reviews, contact_support_link_same, company_name_in_domain_percentage]
  end

  class << self
    
    def sample_algo
      self.new.sample_algo
    end
    
    def predict
      self.new.predict
    end
    
  end

end