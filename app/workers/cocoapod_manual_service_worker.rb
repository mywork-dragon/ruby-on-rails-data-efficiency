class CocoapodManualServiceWorker < CocoapodSdkServiceWorker
  # Class for manually creating SDKs that are *not* available in cocoapods, but can be 'faked' by giving a dummy podspec JSON

  # pod is a JSON string of a podspec
  # example: https://github.com/CocoaPods/Specs/blob/master/Specs/AFNetworking/0.10.0/AFNetworking.podspec.json
  # in podspec form: https://github.com/AFNetworking/AFNetworking/blob/master/AFNetworking.podspec
  # can convert via command line tool
  def initialize(pod)
    @pod = JSON.load(pod)

    # custom properties moved to the top level
    @pod['git'] = @pod['source']['git']
    @pod['http'] = @pod['source']['http']
    @pod['tag'] = @pod['source']['tag']
  end

  # in manual mode, you have to create the ios sdk first
  def update_sdk(sdk_name)
    raise "sdk #{sdk_name} does not exist" if IosSdk.find_by_name(sdk_name).nil?

    super(sdk_name)
  end

  # 
  def get_pod_contents(sdk_name)
    @pod
  end
end