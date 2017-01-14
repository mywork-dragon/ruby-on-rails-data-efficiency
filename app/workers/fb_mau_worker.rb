# Utilities for mapping ios apps to fb apps
# v1: not rated for automated use
class FbMauWorker
  include Sidekiq::Worker

  sidekiq_options retry: false, queue: :fb_mau_scrape

  attr_writer :s3_client

  BUCKET = 'ms-ios-fb-apps'

  def perform(method, *args)
    send(method, *args)
  end

  def s3_client
    @s3_client ||= MightyAws::S3.new
    @s3_client
  end

  def update_ios_apps!(ios_to_fb_map)
    ios_ids = ios_to_fb_map.keys.map(&:to_i)
    IosApp.where(id: ios_ids).each do |ios_app|
      fb_app_id = ios_to_fb_map[ios_app.id.to_s]
      ios_app.update!(fb_app_id: fb_app_id) if ios_app.fb_app_id != fb_app_id
    end
    nil
  end

  def ios_apps_to_fb_apps
    ios_to_fb_apps = calculated_ios_to_fb_apps
    merge_known!(ios_to_fb_apps)
    ensure_single_pair!(ios_to_fb_apps)
    ios_to_fb_apps
  end

  def calculated_ios_to_fb_apps
    cd_map = classdump_map
    convert_cd_to_ios_app_map(cd_map)
  end

  # dumb solution: disqualifies ones with multiple fb ids
  # As of 1/11/2017, ~250
  def ensure_single_pair!(ios_to_fb_apps)
    ios_to_fb_apps.select! { |ios_app_id, fb_ids| fb_ids.count == 1 }
    ios_to_fb_apps.keys.each do |key|
      ios_to_fb_apps[key] = ios_to_fb_apps[key].first
    end
  end

  def merge_known!(ios_to_fb_apps)
    manual = retrieve_known_associations
    manual.each do |ios_app_id, fb_app_id|
      if fb_app_id.nil? # specified null value signals to ensure no match
        ios_to_fb_apps.delete(ios_app_id.to_i)
      else
        ios_to_fb_apps[ios_app_id.to_i] = [fb_app_id]
      end
    end
  end

  # move out for stubbing purposes
  def retrieve_known_associations
    JSON.parse(s3_client.retrieve(
      bucket: BUCKET,
      key_path: 'ios_apps_to_fb_ids.json.gz'
    ))['ios_app_id_to_fb_id']
  end

  def latest_csv_contents
    key_path = s3_client.retrieve(
      bucket: BUCKET,
      key_path: 'latest_classdump_to_app.csv.gz'
    ).strip
    s3_client.retrieve(
      bucket: BUCKET,
      key_path: key_path
    )
  end

  def classdump_map
    csv = latest_csv_contents
    map = CSV.parse(csv).reduce({}) do |memo, row|
      classdump_id = row[0].to_i
      fb_app_id = /^(?:fb)?(\d+)$/.match(row[1]).try(:[], 1).to_i
      if classdump_id > 0 && fb_app_id > 0
        memo[classdump_id] = fb_app_id
      end
      memo
    end
  end

  # we are assuming one ios_app can have multiple fb app ids
  # and one fb_app_id belongs only to one ios_app
  def convert_cd_to_ios_app_map(cd_map)
    apps = fetch_apps(cd_map)

    fb_app_to_ios_app = apps.reduce({}) do |memo, ios_app|
      ios_app_id = ios_app[0]
      cd_id = ios_app[1]
      fb_app_id = cd_map[cd_id]
      if memo[ios_app_id].nil?
        memo[ios_app_id] = [fb_app_id]
      elsif !memo[ios_app_id].include?(fb_app_id)
        memo[ios_app_id] << fb_app_id
      end
      memo
    end
  end

  # separate to allow stubbing
  # returns array of arrays [[ios_app.id, class_dump.id], ...]
  def fetch_apps(cd_map)
    IosApp.joins(:class_dumps)
      .where('class_dumps.id in (?)', cd_map.keys.map(&:to_i))
      .pluck(:id, 'class_dumps.id')
  end
end
