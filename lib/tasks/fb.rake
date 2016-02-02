namespace 'fb' do
  
  desc 'Simulate activity on the facebook accounts'
  task :simulate => [:environment] do
    FbActivityService.simulate
  end

end