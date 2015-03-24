class Ec2Manager

  class << self
  
    def launch
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
 
      ec2                 = Aws::EC2::Client.new(credentials: creds, region: 'us-east-1')            # choose region here
      ami_name            = '*ubuntu-lucid-10.04-amd64-server-20110719'  # which AMI to search for and use
      key_pair_name       = 'proxy'                                      # key pair name
      private_key_file    = "#{ENV['HOME']}/.ssh/matt-housetrip-aws.pem" # path to your private key
      security_group_name = 'proxy'                                      # security group name
      instance_type       = 't1.micro'                                   # machine instance type (must be approriate for chosen AMI)
      ssh_username        = 'ubuntu'                                     # default user name for ssh'ing
 
      resource = Aws::EC2::Resource.new(client: ec2)
 
      #puts ec2.describe_instances
      
      #return
 
      image = resource.images(filters: [{:name=>"image-id",:values=>["ami-84562dec"]}]).first
      
      #image = images.find{ |image| image.name.include('ubuntu') }.first
 
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
      instance = resource.create_instances( :image_id        => image.id, 
                                            :instance_type   => instance_type,
                                            :min_count       => 1,
                                            :max_count       => 1,
                                            :security_group_ids => [security_group.id],
                                            :key_name        => key_pair.name
                                          )
      puts "Launching machine ..."
 
      return
 
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