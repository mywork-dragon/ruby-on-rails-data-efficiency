class CocoapodSdkServiceWorker < CocoapodSdkServiceWorker
  # Class for manually creating SDKs that are available in cocoapods but do not meet download threshold
  def below_minimum_threshold?(pod, downloads)
    false
  end
end