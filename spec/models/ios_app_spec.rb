require "spec_helper"

describe IosApp, type: :model do

  it_behaves_like 'a mobile app', 'ios', 'ipa'

  describe '#store' do
    it { expect(subject.store).to eq('ios') }
  end

  describe '#publisher' do
    let(:publisher) { build(:ios_developer, id: 1234) }
    subject         { build(:ios_app, ios_developer: publisher  ) }

    it { expect(subject.publisher).to eq(publisher) }
  end
end
