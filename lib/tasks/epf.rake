namespace 'epf' do

  desc 'Run iTunes current'
  task :run_itunes_current => [:environment] do
    EpfService.run_itunes_current
  end

  desc "Run iTunes current only if there's a new feed available"
  task :run_itunes_current_if_new_feed_available => [:environment] do
    EpfService.run_itunes_current_if_new_feed_available
  end
  
  
end