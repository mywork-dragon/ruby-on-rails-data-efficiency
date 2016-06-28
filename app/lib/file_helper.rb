class TarHelper

  class << self
    def text_files(path='.')
      `find #{path} -type f -exec grep -Iq . {} \\; -and -print`.chomp.split("\n")
    end

    def tar_text_files(input_directory_path, output_file_path)
      `cd #{input_directory_path} && find . -type f -exec grep . "{}" -Iq \\; -and -print0 | tar cfz #{output_file_path} --null -T -`
      output_file_path
    end

    def untar(path, output_dir)
      `tar -xzf #{path} -C #{output_dir}`
    end
  end

end