require "spec_helper"

describe MicroProxy, type: :model do
  it { expect(subject.defined_enums).to have_key('region') }
  it { expect(described_class.regions).not_to be_empty }

  it { expect(subject.defined_enums).to have_key('purpose') }
  it { expect(described_class.reflect_on_association(:apk_snapshots).macro).to eq(:has_many) }
end
