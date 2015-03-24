class Ec2Manager

  PROXY_PRIVATE_KEY_PATH = '/Users/jason/penpals/important_stuff/proxy.pem'

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
 
      # create the instance (and launch it)
      instance = resource.create_instances( 
                                            image_id: image.id, 
                                            instance_type: instance_type,
                                            min_count: 1,
                                            max_count: 1,
                                            security_group_ids: [security_group.id],
                                            key_name: key_pair.name,
                                            monitoring: {enabled: true} 
                                          ).first
      puts "Launching machine ..."
 
      sleep 0.25  #make sure it's running
      instance.wait_until_running
 
      puts "Running at public IP #{instance.public_ip_address}, private IP #{instance.private_ip_address}!"
           
      # clean up with the following (terminates the machine)
      # instance.delete
      
      instance
    end
    
    def launch_proxy(options={})
      
      region = 'us-east-1'
      region = options[region] if options[region]
      
      instance = launch(
                        image_id: 'ami-84562dec',
                        instance_type: 't1.micro',
                        region: region,
                        key_pair_name: 'proxy', 
                        security_group_name: 'proxy'
                      )
      
      public_ip = instance.public_ip_address
      
      puts "SSHing into proxy (Public IP #{public_ip})"      
      `ssh -i #{PROXY_PRIVATE_KEY_PATH} ubuntu@#{public_ip}`
    
      `sudo su`

      puts "Installing tinyproxy..."
      `sudo apt-get install tinyproxy`
      
      puts 'Editing tinyproxy configuration...'
      `sed -i -e 's/Allow\ 127.0.0.1/#Allow\ 127.0.0.1/g' /etc/tinyproxy.conf`
      
      puts 'Restarting tinyproxy...'
      `sudo service tinyproxy restart`
      
      puts 'Proxy is ready!'
    end
  
  end

end