require "rails_helper"
require '/varys/lib/tasks/one_off/sdks_update_task.rb'

describe SdksUpdateTask do

  describe ".perform" do
    let(:file_name) { 'test_file.csv' }
    let(:stream_name) { 'update_sdks' }
    let(:tag) { FactoryGirl.create(:tag, name: 'Wrong Tag')}

    context "android" do
      let(:platform) { 'android' }
      let(:sdk) { FactoryGirl.create(:android_sdk, id: 1, name: 'Wrong Name') }

      context 'sdk found' do
        let(:file_content) { "ID,Category,New Website,New Name,New Summary\n1,Sports,http://sports.test.com,Sports Test,This is a test sport Sdk" }

        before :each do
          sdk.tags << tag
          subject.perform(file_name, file_content, platform)
        end

        it { expect(AndroidSdk.find(sdk.id).name).to eq('Sports Test') }
        it { expect(AndroidSdk.find(sdk.id).tags.pluck(:name)).to eq(['Sports']) }
        it { expect(AndroidSdk.find(sdk.id).website).to eq('http://sports.test.com') }
        it { expect(AndroidSdk.find(sdk.id).summary).to eq('This is a test sport Sdk') }
      end

      context 'sdk not found' do
        let(:not_found_sdk_id) { 2 }
        let(:file_content) { "ID,Category,New Website,New Name,New Summary\n#{not_found_sdk_id},Sports,http://sports.test.com,Sports Test,This is a test sport Sdk" }

        before :each do
          allow(Rails).to receive_message_chain(:logger, :error)
          allow(MightyAws::Firehose).to receive(:send).with(stream_name: stream_name, data: "#{file_name} = Sdk not found #{not_found_sdk_id}")
          subject.perform(file_name, file_content, platform)
        end

        it { expect(AndroidSdk.exists?(not_found_sdk_id)).to be false }
      end
    end

    # context "ios" do
    #   let(:platform) { 'ios' }
    #   let (:sdks) { FactoryGirl.create_list(:sdk, 2, platform: platform) }

    #   before :each do
    #     subject.perform()
    #   end

    # end

  end

end