class FileRemover

  class << self

    def remove_multimedia_files(directory)
      files = `find #{directory} -type f -and -print0`.split("\0").map{ |f| Shellwords.escape(f)}
      files.each do |file|
        mime_type = `file --brief --mime #{file}`
        `rm #{file}` if ["image", "video", "audio"].any? { |type| mime_type.include?(type) }
      end

      true
    end

  end

end