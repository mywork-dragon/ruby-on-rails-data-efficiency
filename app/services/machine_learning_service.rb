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
    
    
    
  end

  private
  
  #scale reviews down by 5M
  
  def create_vector(percentage_other_apps_same_website: , reviews: , contact_support_link_same: , company_name_in_domain_percentage:)
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