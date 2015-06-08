class CompanyGuessService

  class << self

    def run
      AndroidPackage.where(android_package_tag_id: 0, identified: true).joins(:apk_snapshot).find_each do |package|
        # puts package.id
        classify(package.package_name, package.id)
      end
    end

    def sanitize(string)
      return string.downcase.split(".").uniq
    end

    def features
      features = {}
      for source in @sources
        words = sanitize(source["desc"].to_s)
        for word in words
          if @training_data[word].nil?
            features.store(word, {"good"=>0,"bad"=>0})
          else
            features.store(word, @training_data[word])
          end
        end
      end
      return features
    end

    def doc_count(f)
      count = 0
      for source in @sources
        count += 1 if sanitize(source["desc"]).include? f
      end
      return count
    end

    def cprob(f)
      featureInDocs = @training_data[f]["good"].to_f
      featureTotal = featureInDocs + @training_data[f]["bad"].to_f
      return (featureInDocs/featureTotal).to_f
    end

    def cweight(f, weight = 1, ap = 0.5)
      unless @training_data[f].nil?
        doc_count = doc_count(f).to_f
        cprob = cprob(f)
        @features[f] = ((weight*ap)+(doc_count*cprob))/(weight+doc_count)
      else
        @features[f] = ""
      end
    end

    def doc_prob
      for f in @features
        cweight = cweight(f[0])
      end
      wprobs = []
      for source in @sources
        wprob = 1
        words = sanitize(source["desc"])
        for word in words
          if @features[word] != ""
            wprob = wprob * @features[word]
          end
        end
        wprobs << wprob
      end
      return wprobs
    end

    def inv_chi_2(chi, feat_len)
      m = chi / 2.0
      sum = term = Math.exp(-m)
      (1...(feat_len/2).floor).each do |i|
        term *= m / i
        sum += term
      end
      return [sum, 1.0].min
    end

    def classify(package_name, package_id)
      @cat = "good"
      @features = features()
      res = []
      for prob in doc_prob()
        res << inv_chi_2((-2 * Math.log(prob)), @features.length)
      end
      return res.each_with_index.max[1]
    end

  end

end
