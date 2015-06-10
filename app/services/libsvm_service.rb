class LibsvmService
  
  class << self
    
    def run_sample
      # This library is namespaced.
      problem = Libsvm::Problem.new
      parameter = Libsvm::SvmParameter.new

      parameter.cache_size = 1 # in megabytes

      parameter.eps = 0.001
      parameter.c = 10

      examples = [ [1,0,1], [-1,0,-1] ].map {|ary| Libsvm::Node.features(ary) }
      labels = [1, -1]

      problem.set_examples(labels, examples)

      model = Libsvm::Model.train(problem, parameter)

      pred = model.predict(Libsvm::Node.features(1, 1, 1))
      puts "Example [1, 1, 1] - Predicted #{pred}"
    end
    
    def run
      problem = Libsvm::Problem.new
      parameter = Libsvm::SvmParameter.new

      parameter.cache_size = 1 # in megabytes

      parameter.eps = 0.001
      parameter.c = 10
      
      #inputs: app_is_found
      
      # examples = [ ]

      examples = [ [0, 0, 0, 0], [1, 0, 0, 0], [1, 1, 1, 1], [1, 0, 1, 1] ].map {|ary| Libsvm::Node.features(ary) }
      labels = [0, 1, 1, 1]

      problem.set_examples(labels, examples)

      model = Libsvm::Model.train(problem, parameter)

      # pred = model.predict(Libsvm::Node.features(1, 1, 1))
      pred = model.predict(Libsvm::Node.features(1, 0, 1, 0))
      puts "Example [1, 1, 1] - Predicted #{pred}"
    end
    
    def text_example
      # Let take our documents and create word vectors out of them.
      # I've included labels for these already.  1 signifies that
      # the document was funny, 0 means that it wasn't.
      #
      documents = [[1, "Why did the chicken cross the road? Because a car was coming"],
                   [0, "You're an elevator tech? I bet that job has its ups and downs"]]

      # Lets create a dictionary of unique words and then we can
      # create our vectors.  This is a very simple example.  If you
      # were doing this in a production system you'd do things like
      # stemming and removing all punctuation (in a less casual way).
      #
      dictionary = documents.map(&:last).map(&:split).flatten.uniq
      dictionary = dictionary.map { |x| x.gsub(/\?|,|\.|\-/,'') }

      training_set = []
      documents.each do |doc|
        features_array = dictionary.map { |x| doc.last.include?(x) ? 1 : 0 }
        training_set << [doc.first, Libsvm::Node.features(features_array)]
      end

      # Lets set up libsvm so that we can test our prediction
      # using the test set
      #
      problem = Libsvm::Problem.new
      parameter = Libsvm::SvmParameter.new

      parameter.cache_size = 1 # in megabytes
      parameter.eps = 0.001
      parameter.c   = 10

      # Train classifier using training set
      #
      problem.set_examples(training_set.map(&:first), training_set.map(&:last))
      model = Libsvm::Model.train(problem, parameter)

      # Now lets test our classifier using the test set
      #
      test_set = [1, "Why did the chicken cross the road? To get the worm"]
      test_document = test_set.last.split.map{ |x| x.gsub(/\?|,|\.|\-/,'') }

      doc_features = dictionary.map{|x| test_document.include?(x) ? 1 : 0 }
      pred = model.predict(Libsvm::Node.features(doc_features))
      puts "Predicted #{pred==1 ? 'funny' : 'not funny'}"
    end
    
    
  end
  
end