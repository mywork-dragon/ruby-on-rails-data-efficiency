class SdksUpdateWorker

  include Sidekiq::Worker

  sidekiq_options queue: :skd_update

  S3_BUCKET = 'skd-update'
  MAX_FILE_SIZE = 600000

  def sdk_hotstore
    @sdk_hotstore ||= SdkHotStore.new
  end


  def perform(file_name, file_content, platform)
    skds_data = CSV.parse(file_content, headers: true)
    headers, *skds_data = skds_data.to_a
    fields_map = headers.each_with_index.inject({}){|memo,(name, position)| memo[name] = position and memo }
    sdks_to_update = []
    tags_relationship = []

    sdk_model = "#{platform}_sdk".classify.constantize
    
    begin
      sdk_model.transaction do
        sdks_to_update = skds_data.map do |raw_sdk|
          id = raw_sdk[fields_map['ID']].presence
          category = raw_sdk[fields_map['Category']].presence
          website = raw_sdk[fields_map['New Website']].presence
          name = raw_sdk[fields_map['New Name']].presence
          summary = raw_sdk[fields_map['New Summary']].presence

          tag = Tag.find_or_create_by(name: category)

          begin
            sdk = sdk_model.find(id).tap do |sdk_obj|
              sdk_obj.name = name if name
              sdk_obj.summary = summary if summary
              sdk_obj.website = website if website
              sdk_obj.tags.delete_all
              sdk_obj.tags << tag
            end
            sdk          
          rescue ActiveRecord::RecordNotFound
            logger.error("#{file_name} = Sdk not found #{id}")
            next
          end
        end.compact
        sdk_model.import sdks_to_update, on_duplicate_key_update: [:name, :summary, :website]
        sdks_to_update.each {|updated_sdk| sdk_hotstore.write(platform, updated_sdk.id)}
      end
    rescue => error
      logger.error("#{file_name} = #{error.message}")
    end
  end

  def execute_worker(file_name, platform='ios')
    file_size = MightyAws::S3.new.content_length(bucket: S3_BUCKET, key_path: file_name)
    if file_size <= MAX_FILE_SIZE
      file_content = MightyAws::S3.new.retrieve( bucket: S3_BUCKET, key_path: file_name, ungzip: false )
      SdksUpdateWorker.new.perform(file_name, file_content, platform) if file_content
    else
      p "Couldn't download files bigger than #{MAX_FILE_SIZE}, current size file #{file_size}"
    end
  ensure
    File.delete(file_name) if File.exist?(file_name)
  end

  def enqueue_data(number_of_files=1, filename_prefix='sdks', starting_file=1, platform='ios', file_name=nil)
    if file_name
      file_names = [file_name]
    else
      file_names = (starting_file.to_i..(starting_file.to_i+number_of_files)).map { |n| "#{filename_prefix}#{n}.csv" }
    end
    file_names.each { |file_name| p "processing #{file_name}"; execute_worker(file_name, platform) }
  end
end