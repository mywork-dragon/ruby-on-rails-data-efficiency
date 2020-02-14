require "rails_helper"

shared_examples 'an invalid field' do
  it { expect{ subject }.to raise_error(GooglePlayService::BadGoogleScrape) }
end

describe GooglePlayService do
  describe '.single_app_details' do
    subject { described_class.single_app_details('app_identifier') }

    let(:request_response) do
      JSON.parse(
        File.read(
          Rails.root.join('spec/fixtures/appmonsta_api/android_details_single_app_response_body.json')
        )
      )
    end

    before do
      allow(AppmonstaApi::Base).to receive(:request_single_app_details).and_return(response)
    end

    context 'valid details' do
      let(:response) { request_response }
      it { expect(subject.class).to eq(Hash) }
    end

    context 'invalid details' do

      let(:field) { AppmonstaApi::AndroidMapper::FIELDS_MAP[ms_field] }
      let(:response) { request_response.except!(field).merge!(field => val) }

      describe 'name' do
        let(:ms_field) { :name }
        let(:val) { nil }
        it_behaves_like 'an invalid field'
      end

      describe 'released nil' do
        let(:ms_field) { :released }
        let(:val) { nil }
        it_behaves_like 'an invalid field'
      end

      describe 'released empty' do
        let(:ms_field) { :released }
        let(:val) { '' }
        it_behaves_like 'an invalid field'
      end

      describe 'category_id nil' do
        let(:ms_field) { :category_id }
        let(:val) { nil }
        it_behaves_like 'an invalid field'
      end

      describe 'category_id empty' do
        let(:ms_field) { :category_id }
        let(:val) { '' }
        it_behaves_like 'an invalid field'
      end

      describe 'developer_google_play_identifier nil' do
        let(:ms_field) { :developer_google_play_identifier }
        let(:val) { nil }
        it_behaves_like 'an invalid field'
      end

      describe 'developer_google_play_identifier empty' do
        let(:ms_field) { :developer_google_play_identifier }
        let(:val) { '' }
        it_behaves_like 'an invalid field'
      end

      describe 'description nil' do
        let(:ms_field) { :description }
        let(:val) { nil }
        it_behaves_like 'an invalid field'
      end

      describe 'description empty' do
        let(:ms_field) { :description }
        let(:val) { '' }
        it_behaves_like 'an invalid field'
      end

      describe 'seller nil' do
        let(:ms_field) { :seller }
        let(:val) { nil }
        it_behaves_like 'an invalid field'
      end

      describe 'seller empty' do
        let(:ms_field) { :seller }
        let(:val) { '' }
        it_behaves_like 'an invalid field'
      end

      describe 'downloads nil' do
        let(:ms_field) { :downloads }
        let(:val) { nil }
        it_behaves_like 'an invalid field'
      end

      describe 'downloads empty' do
        let(:ms_field) { :downloads }
        let(:val) { '' }
        it_behaves_like 'an invalid field'
      end

      describe 'downloads string' do
        let(:ms_field) { :downloads }
        let(:val) { 'blah' }
        it_behaves_like 'an invalid field'
      end
    end
  end
end
