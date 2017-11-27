class IosHeaderClassifier
  class << self
    def sdks_from_classnames(classes:, remove_apple: true)
      classes -= AppleDoc.where(name: classes).pluck(:name) if remove_apple

      # DEPRECATED
      # direct_match_info = direct_lookups(classes)
      # direct_match_sdk_ids = direct_match_info[:sdks].map(&:id)

      # classes -= direct_match_info[:matched_classes]

      # use the remaining classes and check the header tables
      matches = IosClassificationHeader.where(name: classes)

      unique_match_sdk_ids = matches.map do |ios_classification_header|
        ios_classification_header.ios_sdk_id if ios_classification_header.is_unique
      end.compact

      collision_sdk_ids = matches.map do |ios_classification_header|
        if ios_classification_header.is_unique
          nil
        elsif (ios_classification_header.collision_sdk_ids & unique_match_sdk_ids).present?
          nil
        else
          ios_classification_header.ios_sdk_id
        end
      end.compact

      ios_sdk_ids = (unique_match_sdk_ids + collision_sdk_ids).uniq

      IosSdk.where(id: ios_sdk_ids)
    end

    def direct_lookups(classes)
      search_terms = classes.map { |name| direct_search_terms_for_name(name) }.flatten.uniq
      
      match_sdks = search_terms.each_slice(15_000).map do |subset|
        IosSdk.where(name: subset)
      end.reduce([], :+)

      match_classes = classes.select do |name|
        terms = direct_search_terms_for_name(name)
        match_sdks.find do |ios_sdk|
          terms.include?(ios_sdk.name)
        end
      end

      {
        sdks: match_sdks,
        matched_classes: match_classes
      }
    end

    def direct_search_terms_for_name(name)
      %w(sdk -ios-sdk -ios -sdk).map { |suffix| name + suffix } + [name]
    end
  end
end
