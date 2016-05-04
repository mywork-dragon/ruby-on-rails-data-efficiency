class AwsApi

  def initialize(region = nil)
    @region = region || 'us-east-1'
  end

  class MalformedInstance < RuntimeError; end
  class UnexpectedCount < RuntimeError; end

  def deploy_ips_for_stage(stage)

    instances = request_filtered_instances(filters: [stage_filter(stage), {name: 'instance-state-name', values: ['running']}])

    ips = extract_ips(instances)

    raise MalformedInstance, "Stage #{stage} contains a box without a valid public ip" if ips.count != ips.compact.count

    ips
  end

  def register_instance_with_lb

    instance_id = AwsInstanceApi.instance_id.to_s

    stage = determine_stage(instance_id)

    lb = lb_for_stage(stage)

    elb_client.register_instances_with_load_balancer(load_balancer_name: lb.load_balancer_name, instances: [{instance_id: instance_id}])

  end

  private

  def ec2_client
    Aws::EC2::Client.new(region: @region)
  end

  def elb_client
    Aws::ElasticLoadBalancing::Client.new(region: 'us-east-1')
  end

  def determine_stage(instance_id)

    resp = ec2_client.describe_instances(instance_ids: [instance_id])

    instances = extract_instances_from_description(resp)

    raise UnexpectedCount, 'Could not find the instance by id' unless instances.count == 1

    instance = instances.first

    stage_tag = instance[:tags].select {|tag| tag.key == 'stage'}.first

    raise MalformedInstance, "Instance #{instance_id} does not have a stage tag" if stage_tag.nil?

    stage = stage_tag.value

    raise MalformedInstance, "Instance #{instance_id} has an empty stage tag value" if stage.nil?

    stage
  end

  def lb_for_stage(stage)

    elb = elb_client

    lbs = elb.describe_load_balancers.load_balancer_descriptions

    raise UnexpectedCount, 'Could not find a load balancer' unless lbs.present? && lbs.count > 0

    names = lbs.map { |lb| lb.load_balancer_name }

    lb_tags = elb.describe_tags(load_balancer_names: names).tag_descriptions

    stage_lbs = lb_tags.select do |lb|
      lb.tags.any? do |tag|
        tag.key == 'stage' && tag.value == stage
      end
    end

    raise UnexpectedCount, "Could not find a load balancer with a stage tag of #{stage}" if stage_lbs.empty?
    raise UnexpectedCount, 'Found multiple lbs with a stage tag' if stage_lbs.count > 1

    target_lb = stage_lbs.first

    target_lb_info = lbs.find {|lb| lb.load_balancer_name == target_lb.load_balancer_name} 

    raise UnexpectedCount, "Could not find load balancer by name #{target_lb.load_balancer_name}" if target_lb_info.nil?

    target_lb_info

  end

  def stage_filter(stage)
    {
      name: 'tag:stage',
      values: [stage]
    }
  end

  def request_filtered_instances(filters: [])

    resp = ec2_client.describe_instances(filters: filters)

    extract_instances_from_description(resp)

  end

  def extract_instances_from_description(resp)

    resp.reservations.map { |reservation| reservation.instances || [] }.flatten

  end

  def extract_ips(instances)

    instances.map { |instance| instance[:public_ip_address] }

  end

end
