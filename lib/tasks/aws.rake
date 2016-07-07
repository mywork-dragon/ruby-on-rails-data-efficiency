namespace 'aws' do

  desc 'Register instance with load balancer'
  task :register_instance => [:environment] do
    MightyAws::Api.new.register_instance_with_lb(app: 'varys')
  end

end
