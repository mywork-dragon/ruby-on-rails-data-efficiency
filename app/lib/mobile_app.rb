module MobileApp
  def ad_attribution_sdks
    tag = Tag.where(id: 24).first
    return [] unless tag

    attribution_sdk_ids = tag.send("#{platform}_sdks").pluck(:id)
    self.installed_sdks.select{|sdk| attribution_sdk_ids.include?(sdk["id"])}
  end

  def is_major_app?
    is_in_top_200? || fortune_rank || follow_relationships.count > 10 || major_publisher?
  end

  def major_app_tag?
    self.tags.any? { |tag| tag.name == "Major App" }
  end
end
