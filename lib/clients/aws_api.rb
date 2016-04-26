class AwsApi

  def initialize(region = nil)
    @region = region || 'us-east-1'
  end

  class UnrecognizedIp < RuntimeError; end

  def deploy_ips_for_stage(stage)

    stage_filters = [{
      name: 'tag:stage',
      values: [stage]
    }]

    instances = request_instances(filters: stage_filters)

    ips = extract_ips(instances)

    raise UnrecognizedIp, "Stage #{stage} contains a box without a valid public ip" if ips.count != ips.compact.count

    ips
  end

  private

  def request_instances(filters: [])

    client = Aws::EC2::Client.new(region: @region)

    resp = client.describe_instances(filters: filters)

    resp.reservations.map { |reservation| reservation.instances || [] }.flatten

  end

  def extract_ips(instances)

    instances.map { |instance| instance[:public_ip_address] }

  end

end
