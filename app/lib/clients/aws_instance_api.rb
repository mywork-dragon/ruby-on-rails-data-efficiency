class AwsInstanceApi

  include HTTParty

  base_uri 'http://169.254.169.254/latest/meta-data'

  def self.instance_id

    get('/instance-id')

  end

end
