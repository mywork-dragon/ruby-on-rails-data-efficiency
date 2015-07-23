class Ec2Manager

  PROXY_PRIVATE_KEY_PATH = '/Users/jason/penpals/important_stuff/proxy.pem'
  TOR_SETUP_SCRIPT_PATH = './server/tor_setup.sh'
  TINYPROXY_SETUP_SCRIPT_PATH = './server/tinyproxy_setup.sh'

  class << self
  
    def launch(options={})
      access_key_id = nil
      secret_access_key = nil
      
      CSV.foreach('/Users/jason/penpals/important_stuff/aws_explorationlabs_rootkey_1.csv', headers: false) do |row|
        text = row.first
        if text.include?('AWSAccessKeyId=')
          access_key_id = text.gsub('AWSAccessKeyId=', '')
        elsif text.include?('AWSSecretKey=')
          secret_access_key = text.gsub('AWSSecretKey=', '')
        end
      end
      
      
      #Aws.config(access_key_id: access_key_id, secret_access_key: secret_access_key)
      creds = Aws::Credentials.new(access_key_id, secret_access_key)        
 
      ec2                 = Aws::EC2::Client.new(credentials: creds, region: options[:region])            # choose region here
      image_id            = options[:image_id]                            # which AMI to search for and use
      key_pair_name       = options[:key_pair_name]                      # key pair name
      security_group_name = options[:security_group_name]                # security group name
      instance_type       = options[:instance_type]                                  # machine instance type (must be approriate for chosen AMI)
      ssh_username        = 'ubuntu'                                     # default user name for ssh'ing
 
      resource = Aws::EC2::Resource.new(client: ec2)
 
      image = resource.images(filters: [{:name=>"image-id",:values=>[image_id]}]).first
 
      puts "image: #{image}"
      
      # find or create a key pair
      
      key_pair = nil
      
      key_pairs = resource.key_pairs
      key_pairs.each do |kp|
        puts kp.name
        if kp.name == key_pair_name
          key_pair = kp
          break
        end
      end
      # puts key_pair = resource.key_pairs[key_pair_name]
      puts "Using keypair #{key_pair.name}"
 
      # find security group
      security_group = resource.security_groups.find{|sg| sg.group_name == security_group_name }
      puts "Using security group: #{security_group.group_name}" 
      
      setup_script = options[:setup_script]
      
      user_data = nil
      
      if setup_script
        if setup_script == :tor
          user_data = Base64.encode64(File.open(TOR_SETUP_SCRIPT_PATH, 'rb') { |f| f.read })
        elsif setup_script == :tinyproxy
          user_data = Base64.encode64(File.open(TINYPROXY_SETUP_SCRIPT_PATH, 'rb') { |f| f.read })
        end
      end
 
      # create the instance (and launch it)
      instance = resource.create_instances( 
                                            image_id: image.id, 
                                            instance_type: instance_type,
                                            min_count: 1,
                                            max_count: 1,
                                            security_group_ids: [security_group.id],
                                            key_name: key_pair.name,
                                            monitoring: {enabled: true},
                                            user_data: user_data
                                            
                                          ).first
      puts "Launching machine ..."
 
      sleep 5.0  #make sure it's running
      instance.wait_until_running
 
      instance.load
 
      puts "Running at public IP #{instance.public_ip_address}, private IP #{instance.private_ip_address}!"
           
      # clean up with the following (terminates the machine)
      # instance.delete
      
      instance
    end
    
    def launch_proxy(region: 'us-east-1')
      
      if region == 'us-east-1'
        image_id = 'ami-84562dec'
        instance_type = 't1.micro'
      end
      
      instance = launch(
                        image_id: image_id,
                        instance_type: instance_type,
                        region: region,
                        key_pair_name: 'proxy', 
                        security_group_name: 'proxy',
                        setup_script: :tinyproxy
                      )
                      
      #configure_proxy_with_tor(instance.instance.ip_address)
      
      instance
    end
    
    def configure_proxy_with_tor(public_ip)
      
      Net::SSH.start(public_ip, 'ubuntu', keys: [PROXY_PRIVATE_KEY_PATH]) do|ssh|
        ssh.request_pty
        puts ssh.exec!('who')
        
        puts 'Becoming the superuser...'
        puts ssh.exec!('sudo su')
  #
  #       puts 'Adding TOR sources for APT...'
  #       add_tor_sources_cmd = %q(sudo cat <<EOF >> /etc/apt/sources.list
  # deb http://deb.torproject.org/torproject.org trusty main
  # deb-src http://deb.torproject.org/torproject.org trusty main
  # EOF)
  #       ssh.exec!(add_tor_sources_cmd)
  #
  #       ssh.exec 'gpg --keyserver keys.gnupg.net --recv 886DDD89'
  #       ssh.exec 'gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -'
  #
  #       puts 'Installing TOR...'
  #       ssh.exec 'apt-get update'
  #       ssh.exec 'apt-get install tor deb.torproject.org-keyring -y'
  #
  #       puts 'Editing TOR configuration...'
  #       edit_tor_config_cmd = %q(cat <<EOF >> /etc/tor/torrc
  # ExitNodes {us}
  #
  # SocksListenAddress `hostname -I`
  # SocksPolicy accept *
  # EOF)
  #       ssh.exec(edit_tor_config_cmd)
  #
  #       puts 'Restarting TOR...'
  #       ssh.exec 'service tor restart'
  #
  #       puts 'Exiting SSH session...'
      end
      
    end
    
    # Launch proxies
    # @param number Number of proxies to launch
    def launch_proxies(number)
      
      ret = []
      
      number.times do |n|
        
        puts "Proxy #{n+1} of #{number}..."
        
        begin
          instance = launch_proxy
          ret << {public_ip: instance.public_ip_address, private_ip: instance.private_ip_address}
        rescue
          puts "Caught Exception. Stopping here."
          break
        end
        
        puts ''
        
      end
      
      ret
    end
  
    def add_proxies_to_db(a)
    
      a.each do |h|
      
        p = Proxy.create!(private_ip: h[:private_ip], public_ip: h[:public_ip], active: true, busy: false)
      
      end
    
    end
  
  end
  

end