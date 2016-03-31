class DbSanitizer

  MAX_STRING_LENGTH = 191

  class << self

    def truncate_string(s)
      return nil if s.nil?
      s.truncate(MAX_STRING_LENGTH)
    end
  end
  
end