module MobileApp
  def ad_attribution_sdks
    tag = Tag.where(id: 24).first
    return [] unless tag

    attribution_sdk_ids = tag.send("#{platform}_sdks").pluck(:id)
    self.installed_sdks.select{|sdk| attribution_sdk_ids.include?(sdk["id"])}
  end

  def tag_as_major_app
    major_tag = Tag.find_by(name: "Major App")
    TagRelationship.find_or_create_by(tag_id: major_tag.id, taggable_id: self.id, taggable_type: self.class.name)
    self.activities.update_all(major_app: true)
  end

  def untag_as_major_app
    major_tag = Tag.find_by(name: "Major App")
    tag = TagRelationship.find_by(tag_id: major_tag.id, taggable_id: self.id, taggable_type: self.class.name)
    tag.destroy
    self.activities.update_all(major_app: false) unless is_major_app?
  end

  def is_major_app?
    is_in_top_200? || fortune_rank || follow_relationships.count > 10 || major_publisher?
  end

  def major_app_tag?
    self.tags.any? { |tag| tag.name == "Major App" }
  end

  def run_length_encode_app_snapshot_fields(snap_table, fields)
    fields.append(:created_at)
    rts = snap_table.pluck(*fields).reject{|x| x[-1].nil?}.group_by {|x| x.first(x.size - 1) }.values
    output = []
    rts.map do |bin|
      bin = bin.select {|x| x[-1]}
      min = bin.map{|x| x[-1]}.min
      max = bin.map{|x| x[-1]}.max
      record = {'start_date' => min, 'stop_date' => max}
      (0..fields.size-2).map {|i| record[fields[i]] = bin[0][i]}
      output.append(record)
    end
    output = output.sort_by {|x| x['stop_date']}
    if output.length > 0
      output[-1]['stop_date'] = nil
    end
    output
  end

end
