class Ec2Launcher

  class << self
  
    def run
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
      
      
      return
      
      AWS.config(:access_key_id     => ENV['HT_DEV_AWS_ACCESS_KEY_ID'],
                 :secret_access_key => ENV['HT_DEV_AWS_SECRET_ACCESS_KEY'])
                 
 
      ec2                 = AWS::EC2.new.regions['eu-west-1']            # choose region here
      ami_name            = '*ubuntu-lucid-10.04-amd64-server-20110719'  # which AMI to search for and use
      key_pair_name       = 'matt-housetrip-aws'                         # key pair name
      private_key_file    = "#{ENV['HOME']}/.ssh/matt-housetrip-aws.pem" # path to your private key
      security_group_name = 'housetrip-basic'                            # security group name
      instance_type       = 't1.micro'                                   # machine instance type (must be approriate for chosen AMI)
      ssh_username        = 'ubuntu'                                     # default user name for ssh'ing
 
      # find the AMI based on name (memoize so only 1 api call made for image)
      image = AWS.memoize do
        ec2.images.filter("root-device-type", "ebs").filter('name', ami_name).first
      end
 
      if image
        puts "Using AMI: #{image.id}"
      else
        raise "No image found matching #{ami_name}"
      end
 
      # find or create a key pair
      key_pair = ec2.key_pairs[key_pair_name]
      puts "Using keypair #{key_pair.name}, fingerprint: #{key_pair.fingerprint}"
 
      # find security group
      security_group = ec2.security_groups.find{|sg| sg.name == security_group_name }
      puts "Using security group: #{security_group.name}" 
 
      # create the instance (and launch it)
      instance = ec2.instances.create(:image_id        => image.id, 
                                      :instance_type   => instance_type,
                                      :count           => 1,
                                      :security_groups => security_group,
                                      :key_pair        => key_pair)
      puts "Launching machine ..."
 
      # wait until battle station is fully operational
      sleep 1 until instance.status != :pending
      puts "Launched instance #{instance.id}, status: #{instance.status}, public dns: #{instance.dns_name}, public ip: #{instance.ip_address}"
      exit 1 unless instance.status == :running
 
      # machine is ready, ssh to it and run a commmand
      puts "Launched: You can SSH to it with;"
      puts "ssh -i #{private_key_file} #{ssh_username}@#{instance.ip_address}"
      puts "Remember to terminate after your'e done!"
           
      # clean up with the following (terminates the machine)
      # instance.delete
      
    end
  
  end

end