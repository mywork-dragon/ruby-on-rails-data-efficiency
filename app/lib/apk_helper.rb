# Helper for inspecting APKs
class ApkHelper

  class << self

    def classes_from_apk(zip_file, copy: false)
      apk = Android::Apk.new(zip_file)
      dex = apk.dex
      classes = dex.classes.map(&:name)
      if copy
        classes_s = classes.join("\n")
        IO.popen('pbcopy', 'w') { |f| f << classes_s }
      end
      classes
    end

    def classes_from_apk_url(url, copy: false)
      zip_file = open(url)
      classes_from_apk(zip_file, copy: copy)
    end

  end

end