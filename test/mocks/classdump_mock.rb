class ClassdumpMock
  ClassDump.new.valid_content_types.each do |sym|
    attr_accessor sym
  end
end
