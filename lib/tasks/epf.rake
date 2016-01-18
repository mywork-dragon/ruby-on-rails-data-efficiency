namespace 'epf' do

  desc 'Run iTunes current'
  task :run_itunes_current => [:environment] do
    EpfService.run_itunes_current
  end

  desc 'Kick off iOS SDK download job for new apps'
  task :scan_new_apps => [:environment] do
    IosEpfScanService.scan_new_apps
  end
  
end