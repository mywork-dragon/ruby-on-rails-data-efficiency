class Zipper
  class NotADirectory < RuntimeError; end

  class << self  

    # puts unzipped directory in same path as zip file
    # Assumes disk has enough space (no size checks)
    def unzip(zip_path, delete: true)
      dir = File.dirname(zip_path)
      outpath = File.join(dir, "#{File.basename(zip_path, '.*')}_unzipped")
      `unzip #{zip_path} -d #{outpath}` # using this rather than rubyzip for speed
      yield outpath if block_given?
    ensure
      FileUtils.rm_rf(outpath) if delete
    end

    # puts zip file in same directory as zipped contents
    def zip(input_dir, delete: true)
      dir = File.dirname(input_dir)
      outpath = File.join(dir, "#{File.basename(input_dir, '.*')}_zipped.zip")
      `cd #{input_dir} && zip -r #{outpath} *` # using this rather than rubyzip for speed
      yield outpath if block_given?
    ensure
      FileUtils.rm_rf(outpath) if delete
    end
  end

  attr_reader :unzipped_path
  attr_reader :zipped_path

  def initialize
    @unzipped_path = nil
    @zipped_path = nil    
  end

  def unzip(zip_path)
    basename = File.basename(zip_path, ".*")  # remove extension too
    basename_escaped = Shellwords.escape(basename)
    random_hex = SecureRandom.hex
    @unzipped_path = "/tmp/#{basename_escaped}_unzipped_#{random_hex}"
    `unzip #{zip_path} -d #{@unzipped_path}`
  end

  def remove_unzipped
    `rm -rf #{@unzipped_path}`
  end

  def zip(path)
    raise NotADirectory unless File.directory?(path)

    basename = File.basename(path)  # remove extension too
    basename_escaped = Shellwords.escape(basename)
    random_hex = SecureRandom.hex

    @zipped_path = "/tmp/#{basename_escaped}_#{random_hex}.zip" 

    `cd #{path} && zip -r #{@zipped_path} *`
  end

  def remove_zipped
    `rm #{@zipped_path}`
  end

  def remove_all
    remove_unzipped
    remove_zipped
    true
  end
end
