# == Schema Information
#
# Table name: class_dumps
#
#  id                       :integer          not null, primary key
#  created_at               :datetime
#  updated_at               :datetime
#  class_dump_file_name     :string(191)
#  class_dump_content_type  :string(191)
#  class_dump_file_size     :integer
#  class_dump_updated_at    :datetime
#  ipa_snapshot_id          :integer
#  success                  :boolean
#  install_success          :boolean
#  dump_success             :boolean
#  teardown_success         :boolean
#  teardown_retry           :boolean
#  duration                 :float(24)
#  install_time             :float(24)
#  dump_time                :float(24)
#  teardown_time            :float(24)
#  error                    :text(65535)
#  trace                    :text(65535)
#  error_root               :text(65535)
#  error_teardown           :text(65535)
#  error_teardown_trace     :text(65535)
#  method                   :string(191)
#  complete                 :boolean
#  error_code               :integer
#  ios_device_id            :integer
#  has_fw_folder            :boolean
#  apple_account_id         :integer
#  app_content_file_name    :string(191)
#  app_content_content_type :string(191)
#  app_content_file_size    :integer
#  app_content_updated_at   :datetime
#  account_success          :integer
#

class ClassDump < ActiveRecord::Base

  class InvalidContentType < RuntimeError; end

  belongs_to :ipa_snapshot
  belongs_to :ios_device
  belongs_to :apple_account

  has_attached_file :class_dump, bucket: Proc.new {|a| a.instance.get_s3_bucket}

  validates_attachment_file_name :class_dump, :matches => [/txt\Z/]

  has_attached_file :app_content, bucket: Proc.new {|a| a.instance.get_s3_bucket}

  validates_attachment_file_name :app_content, :matches => [/tgz\Z/]

  enum error_code: [:devices_busy, :ssh_failure, :no_apple_accounts]

  def get_s3_bucket
    Rails.env.production? ? "varys-apk-files" : "varys-apk-files-development"
  end

  ### getters and setters for classification data
  def s3_client=(value)
    @s3_client = value
  end

  def s3_client
    @s3_client ||= MightyAws::S3.new(Rails.application.config.ios_pkg_summary_bucket_region)
    @s3_client
  end

  def valid_content_types
    %i(classes classdump_txt packages strings files frameworks plist jtool_classes shared_libraries marker)
  end

  def s3_key(content_type)
    raise InvalidContentType unless content_type && valid_content_types.include?(content_type)
    prefix = Digest::SHA1.hexdigest(id.to_s)
    "#{content_type}/#{prefix}.gz"
  end

  def convert_table_format(list)
    CSV.generate do |csv|
      list.each do |item|
        csv << [id, item]
      end
    end
  end

  def extract_table_format(table_str)
    CSV.parse(table_str).map do |rows|
      rows.slice(1..-1)
    end.flatten
  end

  def all_classes
    classes1 = []
    classes2 = []
    begin
      classes1  = classes
    rescue MightyAws::S3::NoSuchKey => e
    end
    begin
      classes2 = jtool_classes
    rescue MightyAws::S3::NoSuchKey => e
    end
    (classes1 + classes2).uniq
  end

  def classes
    retrieve_list(:classes)
  end

  def store_classes(classes)
    store_list(:classes, classes)
  end

  def jtool_classes
    retrieve_list(:jtool_classes)
  end

  def store_jtool_classes(classes)
    store_list(:jtool_classes, classes)
  end

  def shared_libraries
    retrieve_list(:shared_libraries)
  end

  def store_shared_libraries(libraries)
    store_list(:shared_libraries, libraries)
  end

  def classdump_txt
    retrieve_blob(:classdump_txt)
  end

  def store_classdump_txt(classdump_txt)
    store_blob(:classdump_txt, classdump_txt)
  end

  def strings
    list = retrieve_list(:strings)
    list.join("\n")
  end

  # going to store these as rows even though treated as blob in code
  def store_strings(strings)
    cols = strings.split("\n")
    store_list(:strings, cols)
  end

  def packages
    retrieve_list(:packages)
  end

  def store_packages(packages)
    store_list(:packages, packages)
  end

  def files
    retrieve_list(:files)
  end

  def store_files(files)
    store_list(:files, files)
  end

  def frameworks
    retrieve_list(:frameworks)
  end

  def store_frameworks(frameworks)
    store_list(:frameworks, frameworks)
  end

  def plist
    JSON.parse(retrieve_blob(:plist))
  end

  def store_plist(plist_hash)
    store_blob(:plist, plist_hash.to_json)
  end

  def store_processed
    store_blob(:marker, '')
  end

  def processed?
    retrieve_blob(:marker)
    true
  rescue MightyAws::S3::NoSuchKey
    false
  end

  def list_decrypted_binaries
    JSON.parse(s3_client.retrieve(
      bucket: Rails.application.config.ipa_bucket,
      key_path: "binaries_index/#{id}.json.gz"
    ))['decrypted_binary_paths']
  end

  def download_binary(key, file_path)
    s3_client.download_file(
      bucket: Rails.application.config.ipa_bucket,
      key_path: key,
      file_path: file_path
    )
  end

  private

  def retrieve_blob(content_type)
    s3_client.retrieve(
      bucket: Rails.application.config.ios_pkg_summary_bucket,
      key_path: s3_key(content_type)
    ).encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
  end

  def store_blob(content_type, blob)
    s3_client.store(
      bucket: Rails.application.config.ios_pkg_summary_bucket,
      key_path: s3_key(content_type),
      data_str: blob
    )
  end

  def retrieve_list(content_type)
    extract_table_format(retrieve_blob(content_type))
  end

  def store_list(content_type, list)
    s3_client.store(
      bucket: Rails.application.config.ios_pkg_summary_bucket,
      key_path: s3_key(content_type),
      data_str: convert_table_format(list)
    )
  end
end
