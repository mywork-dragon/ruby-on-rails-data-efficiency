namespace 'aws' do

  desc 'Register instance with load balancer'
  task :register_instance => [:environment] do
    AwsApi.new.register_instance_with_lb
  end

end
