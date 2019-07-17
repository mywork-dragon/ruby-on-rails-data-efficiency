require "spec_helper"

describe "Android Publisher", :type => :request do

  before :all do
    headers = {
      "ACCEPT" => "application/json",
    }
  end

  before :each do
    allow_any_instance_of(ApiRequestAnalytics).to receive(:log_request).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:authenticate_client_api_request).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:limit_client_api_call).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:bill_api_request).and_return(true)
  end

  within_subdomain :api do
    it "returns the publisher contacts" do
      FactoryGirl.create(:android_developer)
      expected_result = ["clearbitId", "givenName", "familyName", "fullName", "title", "email", "linkedin"]

      get "/android/publisher/1/contacts", headers

      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.length).to eq(1)
      expect(json_response[0].keys).to match_array(expected_result)
    end

    it "returns error developer not found" do

      get "/android/publisher/5/contacts", headers

      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:not_found)
    end
  end

end
