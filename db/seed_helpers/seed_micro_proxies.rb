def seed_micro_proxies
  puts "creating Micro Proxies"
  disable_logging
  MicroProxy.create!(:active=>true, :public_ip => 'proxy', :private_ip =>'proxy', :purpose => :ios)
  MicroProxy.create!(:active=>true, :public_ip => 'proxy', :private_ip =>'proxy', :purpose => :general)
ensure
  puts "Created MicroProxys: #{MicroProxy.count}"
  enable_logging
end
