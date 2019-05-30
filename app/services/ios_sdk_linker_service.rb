class IosSdkLinkerService
  class << self

    def package_to_cocoapod_helper(start_id: nil)
      IosSdk.joins('LEFT JOIN ios_sdk_links on ios_sdks.id = ios_sdk_links.source_sdk_id').where(source: IosSdk.sources[:package_lookup]).where('ios_sdk_links.source_sdk_id is NULL').where('ios_sdks.id > ?', start_id || 0).find_each do |ios_sdk|
        possible_matches = IosSdk.where("name like '%#{ios_sdk.name}%'").where.not(source: IosSdk.sources[:package_lookup]).where.not(id: ios_sdk.id)

        next if possible_matches.count == 0
        ap "Found #{possible_matches.count} possibilities"

        ap ios_sdk
        puts ""
        ap possible_matches

        print "Connect? [y/n]: "
        ans = gets.chomp

        next unless ans.include?('y')


        if possible_matches.count > 1
          print "Which one? [0...#{possible_matches.count - 1}]: "
          ans = gets.chomp.to_i
        else
          ans = 0
        end

        raise "Bad index" if ans < 0 || ans >= possible_matches.count

        source_sdk_id = ios_sdk.id
        dest_sdk_id = possible_matches[ans].id

        link = IosSdkLink.create!(source_sdk_id: source_sdk_id, dest_sdk_id: dest_sdk_id)

        puts "Created Link for id #{ios_sdk.id}: #{source_sdk_id} --> #{dest_sdk_id}"
        print "Continue? [y/n]: "
        ans = gets.chomp

        unless ans.include?('y')
          ap "Stopped at ios_sdk_id: #{ios_sdk.id}"
          break
        end
      end
    end
  end
end