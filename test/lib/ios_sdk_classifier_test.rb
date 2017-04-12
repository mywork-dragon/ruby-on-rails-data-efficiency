require 'test_helper'
require 'mocks/classdump_mock'
require 'byebug'

class IosSdkClassifierTest < ActiveSupport::TestCase

  def setup
    @cd_mock = ClassdumpMock.new
    @cd_mock.classes = []
    @cd_mock.jtool_classes = []
    @cd_mock.packages = []
    @cd_mock.files = []
    @cd_mock.frameworks = []
    @cd_mock.strings = ''
  end

  test 'it raises exception when no classdumps are available' do
    assert_raises(IosSdkClassifier::NoClassdumps) do
      IosSdkClassifier.new(1234).load_classdump
    end
  end

  test 'loads classdump when available' do
    ipa_snapshot_id = 123
    cd = ClassDump.create!(ipa_snapshot_id: ipa_snapshot_id, dump_success: true)
    classifier = IosSdkClassifier.new(ipa_snapshot_id)
    classifier.load_classdump
    assert_equal cd.id, classifier.classdump.id
  end

  test 'ensures processed' do
    @cd = MiniTest::Mock.new
    @cd.expect(:processed?, true)
    classifier = IosSdkClassifier.new(123)
    classifier.classdump = @cd
    assert_nil classifier.ensure_processed!
  end

  test 'raises when runs out of wait attempts' do
    @cd = MiniTest::Mock.new
    classifier = IosSdkClassifier.new(123)
    classifier.max_waits = 0
    classifier.classdump = @cd
    assert_raises(IosSdkClassifier::Unprocessed) do
      classifier.ensure_processed!
    end
  end

  test 'returns no SDKs when classdump does not have data' do
    classifier = IosSdkClassifier.new(123)
    classifier.classdump = @cd_mock
    classifier.build_results
    results = classifier.results
    results.keys.each do |method|
      assert_equal [], results[method]
    end
  end

  test 'saves results' do
    classifier = IosSdkClassifier.new(123)
    sdks = 3.times.map { |i| IosSdk.create!(kind: :native)}
    classifier.results = {
      classdump: sdks,
      strings: nil
    }
    classifier.save!
    assert_equal 3, IosSdksIpaSnapshot.where(ipa_snapshot_id: 123, method: IosSdksIpaSnapshot.methods[:classdump]).count
    assert_equal 0, IosSdksIpaSnapshot.where(ipa_snapshot_id: 123, method: IosSdksIpaSnapshot.methods[:strings]).count
  end

  test 'ignores results that are excluded' do
    classifier = IosSdkClassifier.new(123, { exclude: IosSdksIpaSnapshot.methods })
    classifier.build_results
    classifier.results.keys.map do |method|
      assert_nil classifier.results[method]
    end
  end

  test 'adjusts existing' do
    prev = IosSdk.create!(kind: :native)
    newer = IosSdk.create!(kind: :native)
    ipa_snapshot_id = 123
    IosSdksIpaSnapshot.create!(ios_sdk_id: prev.id, ipa_snapshot_id: ipa_snapshot_id, method: :classdump)
    IosSdksIpaSnapshot.create!(ios_sdk_id: prev.id, ipa_snapshot_id: ipa_snapshot_id, method: :strings)

    classifier = IosSdkClassifier.new(ipa_snapshot_id)
    classifier.results = {
      classdump: [newer],
      strings: []
    }
    classifier.save!
    assert_equal 1, IosSdksIpaSnapshot.where(
      ipa_snapshot_id: ipa_snapshot_id,
      method: IosSdksIpaSnapshot.methods[:classdump]
    ).count
    assert_equal 0, IosSdksIpaSnapshot.where(
      ipa_snapshot_id: ipa_snapshot_id,
      method: IosSdksIpaSnapshot.methods[:strings]
    ).count
    assert_equal newer.id, IosSdksIpaSnapshot.where(
      ipa_snapshot_id: ipa_snapshot_id,
      method: IosSdksIpaSnapshot.methods[:classdump]
    ).take.ios_sdk_id
  end
end
