# == Schema Information
#
# Table name: ios_reclassification_methods
#
#  id         :integer          not null, primary key
#  method     :integer
#  active     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class IosReclassificationMethod < ActiveRecord::Base

  # this should mirror the method field on IosSdksIpaSnapshot
  # currently, strings are not available to be reclassified
  enum method: [:classdump, :strings, :frameworks, :js_tag_regex, :file_regex, :string_regex, :dll_regex]
end
