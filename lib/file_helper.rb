class FileHelper

  class << self
    def text_files(path='.')
      `find #{path} -type f -exec grep -Iq . {} \\; -and -print`.chomp.split("\n")
    end
  end

end