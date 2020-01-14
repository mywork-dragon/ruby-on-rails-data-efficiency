require 'csv'

desc 'Rename SDKs'
task :rename_sdks => [:environment] do
    file_content = MightyAws::S3.new.retrieve( bucket: 'ms-misc', key_path: 'android_mass_rename_varys.csv', ungzip: false )
    csv = CSV.parse(file_content, headers: true)
    destroyed = []
    renamed = []
    skipped_destroy = []
    skipped_rename = []
    ActiveRecord::Base.transaction do
        csv.each do |row|
            if row['Destroy?'] == 'TRUE'
                begin
                    sdk = AndroidSdk.find row['ID']
                    sdk.destroy
                    destroyed << row['ID']
                rescue
                    skipped_destroy << row['ID']
                end
            else
                begin
                    sdk = AndroidSdk.find row['ID']
                    sdk.update(name: row['Name'], summary: row['Summary'], website: row['Website'])
                    tag = Tag.find_by_name(row['Category'])
                    if tag.present? && sdk.tags.empty?
                        sdk.tags << tag
                    end
                rescue
                    skipped_rename << row['ID']
                end
            end
        end
    end
end