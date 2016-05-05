class AwsInstanceGenerator

  # TODO: allow for custom overriding of options on instance create
  # Allow for more advanced options like additional storage on SDK scrapers

  class InvalidOption < RuntimeError; end

  def initialize
    @aws_api = AwsApi.new
  end

  # Create AWS instances for our varys project servers
  # stage: (:web, :staging, :scraper, etc.)
  # count: number of instances (default 1)
  def create_instances(stage:, count: 1, tags: [])

    raise InvalidOption, "Valid stages are: #{options_map.keys}" unless options_map.keys.include?(stage)
    raise InvalidOption, 'Number of instances has to be greater than 0' unless count.to_i > 0

    # create the instances
    reservation_info = @aws_api.create_instances(options_map[stage].merge({
      count: count
    }))

    # assign tags. Automatically include the stage tag
    tags << {
        key: "stage",
        value: stage.to_s
      }

    reservation_info.instances.each do |instance|
      @aws_api.tag_instance(instance_id: instance.instance_id, tags: tags)
    end

    # return information about all the instances in the reservation
    @aws_api.request_filtered_instances(filters: [{name: 'reservation-id', values: [reservation_info.reservation_id]}])

  end

  def options_by_stage(stage)
    options_map[stage]
  end

  private

  ### Options for each stage can be found in the appropriately named function ###

  def options_map
    {
      web: web_options,
      staging: staging_options,
      scraper: scraper_options,
      migration: migration_options
    }
  end

  def default_instance_options
    {
      image_id: 'ami-fce3c696', # Ubuntu 14.04
      key_name: 'varys-new',
      instance_type: 't2.large'
    }
  end

  def staging_options
    default_instance_options.merge({
      security_groups: ['varys'],
      instance_type: 't2.large'
    })
  end

  def web_options
    default_instance_options.merge({
      security_groups: ['varys'],
      instance_type: 'm4.large'
    })
  end

  def scraper_options
    default_instance_options.merge({
      security_groups: ['worker'],
      instance_type: 'c4.large'
    })
  end

  def migration_options
    default_instance_options.merge({
      security_groups: ['worker'],
      instance_type: 't2.medium'
    })
  end
end
