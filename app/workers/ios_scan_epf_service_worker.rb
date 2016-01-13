class IosScanEpfServiceWorker < IosScanMassServiceWorker

  sidekiq_options backtrace: true, retry: false, queue: :ios_epf_mass_scan

  def initialize
    super
    @start_classify = true
  end
end