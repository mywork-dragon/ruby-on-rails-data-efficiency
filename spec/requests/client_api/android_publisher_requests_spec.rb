require "rails_helper"

describe "Android Publisher", :type => :request do

  let(:android_developer) { create(:android_developer) }

  within_subdomain :api do
    it "returns the publisher contacts" do

      p android_developer.valid_websites

      headers = {
        "ACCEPT" => "application/json",
      }
      get "/android/publisher/1/contacts", headers
  
      expect(response.content_type).to eq("application/json")
      expect(response).to have_http_status(:ok)
    end
  end

end
