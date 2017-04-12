class IosFrameworkClassifier
  class << self
    def find_from_frameworks(frameworks)
      sdks = []
      frameworks.each do |fw_folder|
        regex = convert_folder_to_regex(fw_folder)
        match = IosSdk.where('name REGEXP ?', regex).first
        sdks << match if match
      end
      
      sdks
    end

    # convert a folder name to a regex string (for running against sdk names)
    def convert_folder_to_regex(folder_name)
      regex = folder_name.chomp.split('').map do |char|
        if /[^\p{Alnum}]/.match(char)
          '[^a-zA-Z0-9]?' # mysql doesn't have Alnum...I think
        else
          char
        end
      end.join('')

      # require entire match
      "^#{regex}$"
    end
  end
end
