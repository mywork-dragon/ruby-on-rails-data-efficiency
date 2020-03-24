module AppmonstaApi
  describe AndroidMapper do

    let(:response) do
      JSON.parse(
        File.read(
          Rails.root.join('spec/fixtures/appmonsta_api/android_details_single_app_response_body.json')
        )
      )
    end


    describe '#to_h' do

      subject { described_class.new(response).to_h }

      it 'maps the fields correctly' do
        expect(subject[:name]).to               eq('Messenger – Text and Video Chat for Free')
        expect(subject[:description]).to        eq('Be together whenever with a simple way to text, video chat and rally the group...')
        expect(subject[:seller]).to             eq('Facebook')
        expect(subject[:seller_url]).to         eq('https://www.facebook.com/games/fbmessenger_android/')
        expect(subject[:seller_email]).to       eq('android-support@fb.com')
        expect(subject[:category_name]).to      eq('COMMUNICATION')
        expect(subject[:price]).to              eq('Free')
        expect(subject[:released]).to           eq('January 8, 2020'.to_date)
        expect(subject[:size]).to               be nil
        expect(subject[:top_dev]).to            be false
        expect(subject[:in_app_purchases]).to   be true
        expect(subject[:in_app_purchases_range]).to  eq(99..39999)
        expect(subject[:required_android_version]).to eq('Varies with device')
        expect(subject[:version]).to            eq('Varies with device')
        expect(subject[:downloads]).to          eq(1_000_000_000..5000_000_000)
        expect(subject[:content_rating]).to     eq('Everyone')
        expect(subject[:ratings_all_stars]).to  be 4.2
        expect(subject[:ratings_all_count]).to  eq(70435991)
        expect(subject[:similar_apps]).to       include('com.whatsapp')
        expect(subject[:screenshot_urls]).to    include('https://lh3.googleusercontent.com/f-d7nreVZFtpS7d1Fxc6n2RjYeCN1DzXsorep0iv0thslN0akBNk4ATma5FFPK1jnzaQ')
        expect(subject[:icon_url_300x300]).to   eq('https://lh3.googleusercontent.com/rkBi-WHAI-dzkAIYjGBSMUToUoi6SWKoy9Fu7QybFb6KVOJweb51NNzokTtjod__MzA')
        expect(subject[:developer_google_play_identifier]).to eq('Facebook')
      end
    end
  end
end
