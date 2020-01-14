require 'csv'

desc 'Rename SDKs'
task :rename_sdks => [:environment] do
    file_content = MightyAws::S3.new.retrieve( bucket: 'ms-misc', key_path: 'android_mass_rename_varys.csv', ungzip: false )
    csv = CSV.parse(file_content, headers: true)
    ActiveRecord::Base.transaction do
        csv.each do |row|
            hose = {}
            hose['id'] = row['ID']
            if row['Destroy?'] == 'TRUE'
                begin
                    sdk = AndroidSdk.find row['ID']
                    sdk.destroy!
                    hose['action'] = 'destroyed'
                rescue Exception => e
                    hose['error'] = e
                end
            else
                begin
                    sdk = AndroidSdk.find row['ID']
                    sdk.update!(name: row['Name'], summary: row['Summary'], website: row['Website'])
                    tag = Tag.find_by_name(row['Category'])
                    if tag.present? && sdk.tags.empty?
                        sdk.tags << tag
                    end
                    hose['action'] = 'updated'
                rescue Exception => e
                    hose['error'] = e
                end
            end
            res = MightyAws::Firehose.new.send(stream_name: 'sdk_rename', data: hose.to_json)
        end
    end
end