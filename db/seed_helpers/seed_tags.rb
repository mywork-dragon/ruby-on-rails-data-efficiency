def seed_tags
  disable_logging
  puts 'creating Tags and Tag Relationships'

  tags = %w(Payments Monetization Utilities Networking UI Backend Analytics Social Media)
  tags.concat ['Crash Reporting', 'Game Engine']
  tags.each { |tag_name| Tag.create(name: tag_name) }

  major_publisher_tag_id = Tag.create!(name: 'Major Publisher').id
  major_app_tag_id       = Tag.create!(name: 'Major App').id

  normal_tags_ids = Tag.pluck(:id) - [major_publisher_tag_id, major_app_tag_id]

  ios_ids = IosApp.pluck(:id)
  ios_ids.each do |app_id|
    TagRelationship.create(tag_id: normal_tags_ids.sample, taggable_id: app_id, taggable_type: 'IosSdk')
  end

  andr_ids = AndroidApp.pluck(:id)
  andr_ids.each do |app_id|
    TagRelationship.create(tag_id: normal_tags_ids.sample, taggable_id: app_id, taggable_type: 'AndroidSdk')
  end

  major_app_percentage = 30
  major_ios_apps_ids = ios_ids.sample((ios_ids.size * major_app_percentage/100).to_i)

  major_ios_apps_ids.each do |id|
    TagRelationship.create(tag_id: major_publisher_tag_id, taggable_id: id, taggable_type: 'IosApp')
  end

  # TODO: missing major_publisher tags (there wasn't any in current seed, skipping 'til needed)
ensure
  enable_logging
end
