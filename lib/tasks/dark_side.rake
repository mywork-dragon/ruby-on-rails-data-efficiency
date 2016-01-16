namespace 'dark_side' do

  desc 'Check the status of the redis tunnel and re-enable stuck devices'
  task :mass_tunnel => [:environment] do
    IosMonitorService.broken_redis_fix
  end
end