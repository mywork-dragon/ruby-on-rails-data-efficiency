class FileRemover

  class << self

    def remove_multimedia_files(directory)
      directory = Shellwords.escape(directory)
      pattern_and_print = multimedia_file_exts.map{ |ext| "'*.#{ext.downcase}' -print0" }

      name_args = pattern_and_print.join(" -o -iname ")
      name_args = "-iname " + name_args # for the first one

      find_cmd = "find #{directory} #{name_args}"
      xargs_cmd = "xargs -0 rm"

      `#{find_cmd} | #{xargs_cmd}`
    end

    private

    def multimedia_file_exts
      # https://en.wikipedia.org/wiki/List_of_file_formats

      exts = []

      # image
      exts += %w(
        exif
        gif
        gpl
        grf
        ico
        iff
        jpg
        jpeg
        mng
        png
        psd
        pdd
        raw
        tga
        tif
        tiff
        pdf
      )

      # audio
      exts += %w(
        aif
        aifc
        aiff
        raw
        wav
        m4a
        wav
        wma
        mp2
        mp3
        gsm
        wma
        aac
        mpc
        vqf
      )

      exts += %w(
        aaf
        3gp
        asf
        avchd
        avi
        cam
        dat
        dsh
        fla
        flv
        sol
        m4v
        mkv
        wrap
        mov
        mpeg
        mpg
        mpe
        mxf
        nsv
        ogg
        rm
        svi
        swf
        wmv
        wtv
        yub
      )

      exts.uniq # just in case
    end

  end

end