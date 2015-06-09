class CompanyGuessService

  class << self

    def run_test(package_name="com.facebook.LoginActivity.klkjlkjlkj.dsfsdf.sdfsdf.sdfssd", package_id=1)
      classify(package_name, package_id)
    end

    def run
      AndroidPackage.where(identified: true).joins(:apk_snapshot).find_each do |package|
        classify(package.package_name, package.id)
      end
    end

    def sanitize(string)
      return string.downcase.split(".").uniq
    end

    def features(string)
      words = sanitize(string)
      features = []
      for word in words
        wo = WordOccurence.where(word: word).first
        g, b, e = if wo.blank? then [0, 0, 0] else [wo.good, wo.bad, 1] end
        features.push(word => {"g"=>g,"b"=>b,"e"=>e})
      end
      features
    end

    # def doc_count(feat, feats)
    #   count = 0
    #   for source in @sources
    #     count += 1 if sanitize(source["desc"]).include? f
    #   end
    #   return count
    # end

    def cprob(feat)
      featureInDocs = feat['g'].to_f
      featureTotal = featureInDocs + feat['b'].to_f
      return (featureInDocs/featureTotal).to_f
    end

    # def cweight(feat, weight = 1, ap = 0.5)
    #   feats_p = []
    #   f = feat.to_a[0][1]
    #   unless f['e'] == 0
    #     cprob = cprob(f)
    #     feats_p << ((weight*ap)+(1*cprob))/(weight+1)
    #   end
    #   puts feats_p


    #   # unless @training_data[f].nil?
    #   #   doc_count = doc_count(f).to_f
    #   #   cprob = cprob(f)
    #   #   @features[f] = ((weight*ap)+(doc_count*cprob))/(weight+doc_count)
    #   # else
    #   #   @features[f] = ""
    #   # end
    # end

    def doc_prob(feats)
      for feat in feats
        # cprob = cprob(feat.to_a[0])
        cweight(feat)
      end
      # for f in @features
      #   cweight = cweight(f[0])
      # end
      # wprobs = []
      # for source in @sources
      #   wprob = 1
      #   words = sanitize(source["desc"])
      #   for word in words
      #     if @features[word] != ""
      #       wprob = wprob * @features[word]
      #     end
      #   end
      #   wprobs << wprob
      # end
      # return wprobs
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
      # @cat = "good"
      feats = features(package_name)
      doc_prob(feats)
      # puts feats
      # res = []
      # for prob in doc_prob(feats)
      #   res << inv_chi_2((-2 * Math.log(prob)), @features.length)
      # end
      # return res.each_with_index.max[1]
    end

  end

end
