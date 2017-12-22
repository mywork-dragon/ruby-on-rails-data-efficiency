class Validator
  def compare_responses(v1, v2)
    if v2['updated'] != v1['updated']
      return { v1: v1, v2: v2 }
    end

    keys = ['installed_sdks', 'uninstalled_sdks']
    keys.each do |k|
      v2_wo_activities = v2[k].map { |x| x.delete('activities'); x }
      v1_wo_open_source = v1[k].map { |x| x.delete('open_source'); x }
      v2_wo_activities.each do |sdk_info|
        if not v1_wo_open_source.find { |x| is_equal_info(sdk_info, x) }
          return {
            needle: sdk_info,
            haystack: v1_wo_open_source
          }
        end
      end
      v1_wo_open_source.each do |sdk_info|
        if not v2_wo_activities.find { |x| is_equal_info(sdk_info, x) }
          puts 'New response missing data'
          return {
            needle: sdk_info,
            haystack: v2_wo_activities
          }
        end
      end
    end
    true
  end

  def is_equal_info(x, y)
    # exact_keys = ['name', 'id', 'website', 'favicon']
    exact_keys = ['name', 'id', 'website']
    res = true
    exact_keys.each do |k|
      res = (res && x[k] == y[k])
    end

    return res if res == false

    date_keys = ['first_seen_date', 'last_seen_date', 'first_unseen_date']
    date_keys.each do |k|
      r2 = if x[k].present? && y[k].present?
             tx = DateTime.parse(x[k]).to_i
             ty = DateTime.parse(y[k]).to_i
             diff = tx > ty ? tx - ty : ty - tx
             diff < 1 ? true : false
            elsif x[k].present? || y[k].present?
              false
            else
              true
            end
      res = res && r2
    end
    res
  end

  def validate_id(id, platform)
    v1 = JSON.parse(MightyAws::S3.new.retrieve(bucket: 'ms-scratch', key_path: "testing/#{platform}/v1/#{id}.json.gz"))
    v2 = JSON.parse(MightyAws::S3.new.retrieve(bucket: 'ms-scratch', key_path: "testing/#{platform}/v2/#{id}.json.gz"))
    res = compare_responses(v1, v2)
    if res != true && investigate_first_seen? && is_known_first_seen_problem?(res, id)
      true
    else
      res
    end
  rescue MightyAws::S3::NoSuchKey
    puts "missing"
    true
  end

  def validate_many(app_ids, platform)
    app_ids.each_with_index do |id, i|
      puts "#{i}/#{app_ids.count}"
      res = validate_id(id, platform)
      if res != true
        puts id
        res[:id] = id
        return res
      end
    end
  end

  def investigate_first_seen?
    true
  end

  def is_known_first_seen_problem?(res, id)
    snaps = IpaSnapshot.where(ios_app_id: id, scan_status: 1)
    a = res[:needle]
    b = res[:haystack].select {|x| a['id'] == x['id']}.first
    old_res = a['first_seen_date'].include?('.000Z') ? a : b
    new_res = a['first_seen_date'].include?('.000Z') ? b : a

    old_snap = snaps.where(first_valid_date: DateTime.parse(old_res['first_seen_date'])).first
    new_snap = snaps.where(first_valid_date: DateTime.parse(new_res['first_seen_date'])).first
    if DateTime.parse(new_res['first_seen_date']) > DateTime.parse(old_res['first_seen_date']) &&
        old_snap.good_as_of_date > new_snap.good_as_of_date &&
        old_snap.first_valid_date < new_snap.first_valid_date
      puts 'first seen issue'
      puts "#{old_res['first_seen_date']} --> #{new_res['first_seen_date']}"
      true
    else
      false
    end
  end

  def investigate_first_unseen?
    true
  end

  def is_known_first_unseen_problem?(res, id)
    snaps = IpaSnapshot.where(ios_app_id: id, scan_status: 1)
    a = res[:needle]
    b = res[:haystack].select {|x| a['id'] == x['id']}.first
    return false unless a['first_unseen_date'] && b['first_unseen_date']
    old_res = a['first_unseen_date'].include?('.000Z') ? a : b
    new_res = a['first_unseen_date'].include?('.000Z') ? b : a
    if DateTime.parse(new_res['first_unseen_date']) > DateTime.parse(old_res['first_unseen_date']) &&
        old_snap.good_as_of_date > new_snap.good_as_of_date &&
        old_snap.first_valid_date < new_snap.first_valid_date
      puts 'unseen issue'
      puts "#{old_res['first_unseen_date']} --> #{new_res['first_unseen_date']}"
      true
    else
      false
    end
  end

  def ignore_ids_ios
    # 3485369, 236313 - first seen discrepency
    # 2684382, 333684 - DEFAULT_FAVICON is now null
    [759716, 568517]
  end

  def ignore_ids_android
    []
  end

  def test_ios
    ids = JSON.parse(MightyAws::S3.new.retrieve(bucket: 'ms-scratch', key_path: "testing/ios_ids.json.gz"))
    validate_many(ids - ignore_ids_ios, 'ios')
    nil
  end

  def test_android
    ids = JSON.parse(MightyAws::S3.new.retrieve(bucket: 'ms-scratch', key_path: "testing/android_ids.json.gz"))
    validate_many(ids - ignore_ids_android, 'android')
    nil
  end

  def compare_diff(res)
    a = res[:needle]
    b = res[:haystack].select {|x| a['id'] == x['id']}.first
    [a, b]
  end

  def ignore_first_seen
    false
  end

  def investigate_first_seen(res)
    snaps = IpaSnapshot.where(ios_app_id: res[:id], scan_status: 1)
    a_snap = snaps.where(first_valid_date: DateTime.parse(a['first_seen_date'])).first
    b_snap = snaps.where(first_valid_date: DateTime.parse(b['first_seen_date'])).first
    return [a_snap, b_snap]
  end

end
