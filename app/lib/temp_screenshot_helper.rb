class TempScreenshotHelper

  def temp_image_file(image_info)
    decoded_file = Base64.decode64(image_info)
    file = Tempfile.new([filename_from_image(image_info), '.png'])
    file.binmode
    file.write decoded_file
    file
  end

private

  def filename_from_image(image_info)
    md5 = Digest::MD5.new
    md5 << image_info
    md5.hexdigest
  end

end