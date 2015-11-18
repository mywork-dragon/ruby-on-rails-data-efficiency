class AppleDocService

  DUMP_PATH = Rails.env.production? ? File.join('echo $HOME'.chomp, 'ios_headers') : '/tmp/ios_headers'

  class << self

    def populate_docs
      return 'Git must be installed' if `which git`.chomp.blank?

      puts "Downloading".blue
      `git clone https://github.com/nst/iOS-Runtime-Headers.git #{DUMP_PATH}`

      files = Dir.glob("#{DUMP_PATH}/**/*.h")

      files.each do |file|
        contents = File.open(file) {|f| f.read}
        matches = contents.scan(/(?:@interface|@protocol)\s+([^\s]*)/).flatten.uniq

        matches.each do |name|
          begin
            AppleDoc.find_or_create_by(name: name)
          rescue ActiveRecord::RecordNotUnique => e
            nil
          end
        end
      end
    end
  end
end