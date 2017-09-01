class TempScreenshotHelperMock

  def initialize(file)
    @file = file
  end

  def temp_image_file(image_info)
    return @file
  end

end
