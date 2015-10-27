namespace 'epf' do

  desc 'Run iTunes current'
  task :run_itunes_current => [:environment] do
    EpfService.run_itunes_current
  end
  
  
end