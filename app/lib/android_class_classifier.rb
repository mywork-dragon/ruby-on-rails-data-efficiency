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

  def initialize(model_file = "db/android_class_model/model.json")
    @model_file = model_file
    @downloaded = false
  end

  def download!
    if @model_file.start_with?('s3')
      bucket = @model_file.split("//")[1].split('/')[0]
      key = @model_file.split('//')[1].split('/')[1..-1].join('')
      client = MightyAws::S3.new
      content = client.retrieve(
        bucket: bucket,
        key_path: key
      )
    else
      @model_file = File.join(Rails.root, @model_file)
      content = File::open(@model_file).read()
    end

    # model_file is a json file.
    m = JSON.parse(content)
    @class_to_sdks = m['class_to_sdks']
    @sdk_to_website = m['sdk_to_website']
    @downloaded = true
  end

  def ensure_downloaded!
    return if @downloaded
    download!
  end

  def classify(classes)
    ensure_downloaded!
    sdks = Set.new
    unconsumed_classes = []
    path_to_sdk = {}

    classes.each do |klass|
      if @class_to_sdks.include? klass
        sdk = @class_to_sdks[klass]
        web = @sdk_to_website.include?(sdk) ? @sdk_to_website[sdk] : ""
        sdks.add([sdk, web])
        path_to_sdk[klass] = sdk
      end
    end
    [sdks, path_to_sdk]
  end

end
