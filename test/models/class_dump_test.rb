require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class ClassDumpTest < ActiveSupport::TestCase
  def setup
    @s3 = MightyAwsS3Mock.new
    @classdump = ClassDump.create!
    @classdump.s3_client = @s3
  end

  test 'invalid s3 key' do
    assert_raises(ClassDump::InvalidContentType) { @classdump.s3_key(nil) }
    assert_raises(ClassDump::InvalidContentType) { @classdump.s3_key(:dne) }
  end

  test 'valid s3 key' do
    assert_equal "classes/#{Digest::SHA1.hexdigest(@classdump.id.to_s)}.gz", @classdump.s3_key(:classes)
  end

  test 'store and retrieve classes' do
    generic_store_and_retrieve_test(['one', 'two', 'three'], :classes)
  end

  test 'store and retrieve classdump' do
    generic_store_and_retrieve_test('Just a normal string', :classdump_txt)
  end

  # known failure case: strings that end with newline do not get newline added back
  test 'store and retrieve strings' do
    generic_store_and_retrieve_test("asdfadsf\nas;dfjasdfa", :strings)
  end

  test 'store and retrieve packages' do
    generic_store_and_retrieve_test(['com.google.admob', 'com.stupid,name.hello'], :packages)
  end

  test 'store and retrieve files' do
    generic_store_and_retrieve_test(['/hello.app/appcode.txt', 'com.asdfasdfasdf.asdfadsf'], :files)
  end

  test 'store and retrieve frameworks' do
    generic_store_and_retrieve_test(['Apsalar-iOS-SDK', 'MySDK'], :frameworks)
  end

  test 'store and retrieve plist' do
    generic_store_and_retrieve_test({hey: 'sup', yo: 123123}.as_json, :plist)
  end

  test 'store and retrieve jtool classes' do
    generic_store_and_retrieve_test(['cool_class', '_TtC5Venmo5Class'], :jtool_classes)
  end

  test 'store and retrieve shared libraries' do
    generic_store_and_retrieve_test(['@rpath/Frameworks/Alamofire', '/System/Frameworks/Something'], :shared_libraries)
  end

  test 'list decrypted binaries' do
    @s3.store(
      bucket: Rails.application.config.ipa_bucket,
      key_path: "binaries_index/#{@classdump.id}.json.gz",
      data_str: { 'decrypted_binary_paths' => ['asdf', '123', 'qwer'] }.to_json)
    res = @classdump.list_decrypted_binaries
    assert res.class == Array
    assert_equal "binaries_index/#{@classdump.id}.json.gz", @s3.key_returned_from
  end

  test 'check processed' do
    assert_equal false, @classdump.processed?

    @classdump.store_processed
    assert_equal '', @s3.data

    assert_equal true, @classdump.processed?
  end

  def generic_store_and_retrieve_test(input, input_type)
    map = {
      classes: { in: :store_classes, out: :classes },
      classdump_txt: { in: :store_classdump_txt, out: :classdump_txt },
      strings: { in: :store_strings, out: :strings },
      packages: { in: :store_packages, out: :packages },
      files: { in: :store_files, out: :files },
      frameworks: { in: :store_frameworks, out: :frameworks },
      plist: { in: :store_plist, out: :plist },
      jtool_classes: { in: :store_jtool_classes, out: :jtool_classes },
      shared_libraries: { in: :store_shared_libraries, out: :shared_libraries }
    }

    methods = map[input_type]
    raise 'No registered store and retrieve methods' unless methods

    @classdump.send(methods[:in], input)
    output = @classdump.send(methods[:out])

    assert_equal input, output
    assert_equal @s3.key_stored_to, @s3.key_returned_from
  end
end
