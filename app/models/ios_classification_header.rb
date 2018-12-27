# == Schema Information
#
# Table name: ios_classification_headers
#
#  id                :integer          not null, primary key
#  name              :string(191)
#  ios_sdk_id        :integer
#  is_unique         :boolean
#  collision_sdk_ids :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class IosClassificationHeader < ActiveRecord::Base
  serialize :collision_sdk_ids, Array

  def s3_client=(value)
    @s3_client = value
  end

  def s3_client
    @s3_client ||= MightyAws::S3.new(Rails.application.config.ios_pkg_summary_bucket_region)
    @s3_client
  end

  def model_summary
    res = {}
    self.class.find_each do |header_row|
      res[header_row.name] = {
        ios_sdk_id: header_row.ios_sdk_id,
        is_unique: header_row.is_unique,
        collision_sdk_ids: header_row.collision_sdk_ids
      }
    end
    res
  end

  def store_at_location(summary, s3_key_path)
    s3_client.store(
      bucket: Rails.application.config.ios_classification_models_bucket,
      key_path: s3_key_path,
      data_str: summary.to_json
    )
  end

  def publish_daily
    summary = model_summary
    timestamp = DateTime.now.utc
    s3_key_path = File.join('models', timestamp.strftime('%Y/%m/%d'), "#{timestamp.iso8601}.json.gz")
    store_at_location(summary, s3_key_path)
    publish_latest(summary: summary)
  end

  def publish_latest(summary: model_summary)
    s3_key_path = 'models/latest.json.gz'
    store_at_location(summary, s3_key_path)
  end
end
