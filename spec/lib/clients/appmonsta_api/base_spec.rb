require 'spec_helper'

module AppmonstaApi
  describe Base do
    describe '.get_single_app_details' do

      before do
        stub_const("#{described_class}::BASE_URI", 'http://apiurl.com')
      end

      let(:app_identifier) { 'app_identifier_123' }

      subject { described_class.get_single_app_details(platform, app_identifier) }


      context 'android' do
        let(:platform)        { 'android' }
        let(:response)        { instance_double(HTTParty::Response, parsed_response: body_response, code: http_code ) }
        let(:body_response)   { 'some stuff' }

        before do
          allow(described_class).to receive(:get) { response }
        end

        context 'success' do
          let(:http_code) { 200 }
          it { expect(subject).to eq(body_response) }
        end

        context 'error' do
          describe 'BadRequest' do
            let(:http_code) { 400 }
            it { expect { subject }.to raise_error(RequestErrors::BadRequest)  }
          end
          describe 'Unauthorized' do
            let(:http_code) { 401 }
            it { expect { subject }.to raise_error(RequestErrors::Unauthorized)  }
          end
          describe 'NotAllowed' do
            let(:http_code) { 403 }
            it { expect { subject }.to raise_error(RequestErrors::NotAllowed)  }
          end
          describe 'NotFound' do
            let(:http_code) { 404 }
            it { expect { subject }.to raise_error(RequestErrors::NotFound)  }
          end
          describe 'RateLimitExceeded' do
            let(:http_code) { 429 }
            it { expect { subject }.to raise_error(RequestErrors::RateLimitExceeded)  }
          end
          describe 'InternalServerErrror' do
            let(:http_code) { 500 }
            it { expect { subject }.to raise_error(RequestErrors::InternalServerErrror)  }
          end
        end
      end

      context 'unknown' do
        let(:platform)        { 'somethingelse' }
        it { expect { subject }.to raise_error(/Platform/)  }
      end
    end
  end
end
