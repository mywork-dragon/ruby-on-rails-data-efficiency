require 'test_helper'

class SyntaxTest < ActiveSupport::TestCase
  
  def setup
    directories = ['/app/models/*.rb', '/app/controllers/*.rb', 'app/services/*.rb', 'jobs/*.rb']
  
    @class_files = []
  
    directories.each do |directory|
      Dir.glob(Rails.root + directory).each { |file| @class_files << file }
    end
    
    # puts "Class Files"
    # puts "-----------"
    # puts @class_files.join("\n")
  end



  test "Ruby classes should have valid syntax" do
    @class_files.each do |file|
      output = `ruby -c #{file}`.strip
      assert (output == "Syntax OK"), "#{file} failed the syntax test"
    end
  end
  
end