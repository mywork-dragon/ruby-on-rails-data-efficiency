require "rails_helper"

describe Api::ItunesChartsRankingsController, type: :request do

  describe '.request_charts_rankings' do
    let(:storefront_id) { '1234' }
    let(:params) { {storefront_id: storefront_id } }
    subject { get '/api/itunes_charts_rankings/request_charts_rankings', params }

    it 'receives the request' do
      expect(ItunesChartService).to receive(:get_storefront_charts).with(storefront_id)
      subject
    end


  end
end
