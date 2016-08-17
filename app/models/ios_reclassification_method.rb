class IosReclassificationMethod < ActiveRecord::Base

  # this should mirror the method field on IosSdksIpaSnapshot
  # currently, strings are not available to be reclassified
  enum method: [:classdump, :strings, :frameworks, :js_tag_regex, :file_regex, :string_regex, :dll_regex]
end
