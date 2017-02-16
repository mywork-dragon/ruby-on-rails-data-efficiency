require 'test_helper'

class JtoolTest < ActiveSupport::TestCase

  def setup
    @jtool = Jtool.new
    @test_binary_path = File.join('test', 'data', 'random_app.decrypted')

    if /Darwin/.match(`uname`.chomp)
      @jtool.timeout_exec = 'gtimeout'
      @jtool.jtool_exec = File.join('.', 'bin', 'jtool')
    else
      @jtool.jtool_exec = File.join('.', 'bin', 'jtool.ELF64')
    end
  end

  test 'Dumps classes for decrypted binary' do
    classes = @jtool.objc_classes(@test_binary_path)
    assert classes.include?('AdMob')
  end

  test 'gets shared libraries for decrypted binary' do
    libraries = @jtool.shared_libraries(@test_binary_path)
    assert libraries.include?('/System/Library/Frameworks/GameKit.framework/GameKit')
  end
end
