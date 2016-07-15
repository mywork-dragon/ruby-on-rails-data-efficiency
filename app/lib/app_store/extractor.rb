# Extract attributes from different data sources into our internal lexicon 

require_relative 'extractor_json'
require_relative 'extractor_html'

module AppStoreHelper
  class Extractor
    attr_accessor :extractor

    class InvalidInput < RuntimeError; end

    def initialize(data_str, type:)
      raise InvalidInput unless extractor_types.keys.include?(type)
      @extractor = extractor_types[type].new(data_str)
    end

    def extractor_types
      {
        json: AppStoreHelper::ExtractorJson,
        html: AppStoreHelper::ExtractorHtml
      }
    end

    # Move all the methods on the extractor helper
    def method_missing(m, *args, &block)
      @extractor.send(m, *args, &block)
    end

    def self.test
      txt = File.open(File.join(Rails.root, 'uber.ignore.json')) { |f| f.read }
      new(txt, type: :json)
    end
  end
end
