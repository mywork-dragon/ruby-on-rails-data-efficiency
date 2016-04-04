class Zipper
  
  class << self  

    def unzip(zip_path, delete: true)
      raise NoBlockGiven, "You need to pass a block with argument unzipped_path" unless block_given?

      basename = File.basename(zip_path, ".*")  # remove extension too
      basename_escaped = Shellwords.escape(basename)
      random_hex = SecureRandom.hex
      unzipped_path = "/tmp/#{basename_escaped}_unzipped_#{random_hex}"
      `unzip #{zip_path} -d #{unzipped_path}`

      yield unzipped_path

      `rm -rf #{unzipped_path}` if delete
    end

    def zip(path, delete: true)
      raise NoBlockGiven, "You need to pass a block with argument zipped_path" unless block_given?
      raise NotADirectory unless File.directory?(path)

      basename = File.basename(path)  # remove extension too
      basename_escaped = Shellwords.escape(basename)
      random_hex = SecureRandom.hex

      zipped_path = "/tmp/#{basename_escaped}_#{random_hex}.zip" 

      `cd #{path} && zip -r #{zipped_path} *`

      yield zipped_path

      `rm #{zipped_path}` if delete
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

  class NoBlockGiven < StandardError

    def initialize(message = "You need to pass a block")
      super
    end

  end

  class NotADirectory < StandardError

    def initialize(message = "Must be a directory")
      super
    end

  end


end