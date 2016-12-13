# AndroidPackageClassifier
# Reads a android classification model produced
# by https://github.com/MightySignal/android-classification
# and uses it to classify android classes.

class AndroidClassClassifier
  class PackageNode < Hash
    attr_accessor :info
    def initialize(info)
      @info = info
    end
  end
  def initialize(model_file = "db/android_class_model/model.json.gz")
    model_file = File.join(Rails.root, model_file)
    # model_file is a gzipped json file.
    m = JSON.parse(Zlib::GzipReader.open(model_file).read())
    @class_to_sdks = m['class_to_sdks']
    @sdk_to_website = m['sdk_to_website']
  end

  def classify(classes)
    sdks = Set.new
    unconsumed_classes = []
    path_to_sdk = {}

    classes.each do |klass|
      if @class_to_sdks.include? klass
        sdk = @class_to_sdks[klass]
        web = @sdk_to_website.include? sdk ? @sdk_to_website[sdk] : ""
        sdks.add([sdk, web])
        path_to_sdk[klass] = sdk
      end
    end
    [sdks, path_to_sdk]
  end

end
