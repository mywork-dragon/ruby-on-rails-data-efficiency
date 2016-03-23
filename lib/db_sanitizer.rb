class DbSanitizer

  MAX_STRING_LENGTH = 191

  class << self

    def truncate_string(s)
      s.truncate(MAX_STRING_LENGTH)
    end
  end
  
end