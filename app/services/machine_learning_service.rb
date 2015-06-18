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
  
  def predict(app_identifier)
    problem = Libsvm::Problem.new
    parameter = Libsvm::SvmParameter.new

    parameter.cache_size = 1 # in megabytes

    parameter.eps = 0.001
    parameter.c = 10
    
    # Dropbox, Tinder, MySpace, Papa John's Pizza, Children Study Lounge, Pulsepoint, Sheetal Sheth, Amazing Facts, Gay Times - the original gay lifestyle magazine, Bills Tracker for iPhone/iPad
    training_ss_ids = [3756292, 3635886, 3690092, 3312993, 3596641, 3390829, 3547939, 2961514, 3474788, 2969821]
    labels = [1, 1, 1, 1, 1, 0, 0, 0, 0, 0]
    
    examples_a = training_ss_ids.map do |ss_id|
      vector_from_ss_id(ss_id)
    end
    
    # puts "labels: #{labels}"
    # puts "examples: #{examples}"
    
    examples = examples_a.map {|ary| Libsvm::Node.features(ary) }
    
    problem.set_examples(labels, examples)
    
    return
    
    model = Libsvm::Model.train(problem, parameter)
    
    ios_app = IosApp.find_by_app_identifier(app_identifier)
    
    ss = ios_app.newest_ios_app_snapshot

    model.predict(Libsvm::Node.features(vector_from_ss_id(ss.id)))
  end
  
  def vector_from_ss_id(ss_id)
    ss = IosAppSnapshot.find(ss_id)
    
    appearances = IosAppSnapshot.where(ios_app_snapshot_job_id: ss.ios_app_snapshot_job_id, seller_url: ss.seller_url, developer_app_store_identifier: ss.developer_app_store_identifier).count
    total = IosAppSnapshot.where(ios_app_snapshot_job_id: ss.ios_app_snapshot_job_id, developer_app_store_identifier: ss.developer_app_store_identifier).count
    percentage_other_apps_same_website = (appearances.to_f)/(total.to_f)
    
    contact_support_link_same = nil
    if ss.seller_url.blank? || ss.support_url.blank?
      contact_support_link_same = 0
    else
      contact_support_link_same = UrlHelper.url_with_domain_only(ss.seller_url) == UrlHelper.url_with_domain_only(ss.support_url) ? 1 : 0
    end
    
    reviews = ss.ratings_all_count/5.0e6
    
    white = Text::WhiteSimilarity.new
    company_name_in_domain_percentage = 0
    company_name_in_domain_percentage = white.similarity(ss.seller, UrlHelper.url_with_domain_only(ss.seller_url)) unless ss.seller_url.blank?
    
    create_vector(percentage_other_apps_same_website: percentage_other_apps_same_website, reviews: reviews, contact_support_link_same: contact_support_link_same, company_name_in_domain_percentage: company_name_in_domain_percentage)
  end

  
  #scale reviews down by 5M
  
  def create_vector(percentage_other_apps_same_website:, reviews:, contact_support_link_same:, company_name_in_domain_percentage:)
    [percentage_other_apps_same_website, reviews, contact_support_link_same, company_name_in_domain_percentage].map{ |x| x.to_f }
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