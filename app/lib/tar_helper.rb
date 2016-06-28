class TarHelper

  class << self
    def text_files(path='.')
      `find #{path} -type f -exec grep -Iq . {} \\; -and -print`.chomp.split("\n")
    end

    def tar_text_files(path)
      `cd #{path} && find . -type f -exec grep . "{}" -Iq \\; -and -print0 | tar cfz ../test.tgz --null -T -`
    end

    def untar(path, output_dir)
      `tar -xzf #{path} -C #{output_dir}`
    end
  end

end