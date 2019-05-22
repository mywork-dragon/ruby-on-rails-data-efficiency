# This seems to be a one time job?

# class SdkTagService
#
#   class << self
#
#     def tag_sdks
#       CSV.foreach("sdks.csv", {:headers=>:first_row}) do |row|
#         next unless row["sdk_type"].present?
#         row["sdk_type"].split(",").each do |tag_id|
#           tag = Tag.find(tag_id)
#           sdk = IosSdk.find(row["Sdk id"])
#           tag.ios_sdks << sdk unless tag.ios_sdks.include?(sdk)
#         end
#       end
#     end
#   end
# end
