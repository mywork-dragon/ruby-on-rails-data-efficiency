require 'spec_helper'

module AppmonstaApi
  describe AppmonstaAndroidSingleResponse do

    let(:response) do
      JSON.parse(
        File.read(
          Rails.root.join('spec/fixtures/appmonsta_api/android_details_single_app_response_body.json')
        )
      )
    end

    subject { described_class.new(response) }

    it 'maps the response' do
      expect(subject.content_rating).to     eq('Everyone')
      expect(subject.app_name).to           eq('Messenger – Text and Video Chat for Free')
      expect(subject.top_developer).to      be false
      expect(subject.publisher_id_num).to   eq('5629993546372213086')
      expect(subject.requires_os).to        eq('Varies with device')
      expect(subject.related).to            include('related_apps' => array_including('com.whatsapp'))
      expect(subject.video_urls).to         include('https://someurl.com')
      expect(subject.file_size).to          eq('Varies with device')
      expect(subject.publisher_name).to     eq('Facebook')
      expect(subject.price_currency).to     eq('USD')
      expect(subject.genres).to             include('Communication')
      expect(subject.app_type).to           eq('APPLICATION')
      expect(subject.icon_url).to           eq('https://lh3.googleusercontent.com/rkBi-WHAI-dzkAIYjGBSMUToUoi6SWKoy9Fu7QybFb6KVOJweb51NNzokTtjod__MzA')
      expect(subject.content_rating_info).to be_empty
      expect(subject.interactive_elements).to eq('Users Interact, Shares Location, Digital Purchases')
      expect(subject.version).to            eq('Varies with device')
      expect(subject.publisher_url).to      eq('https://www.facebook.com/games/fbmessenger_android/')
      expect(subject.contains_ads).to       be false
      expect(subject.whats_new).to          eq('In efforts to make it easier to connect with businesses on Messenger, we are focusing on more contextual...')
      expect(subject.publisher_id).to       eq('Facebook')
      expect(subject.price).to              eq('Free')
      expect(subject.screenshot_urls).to    include('https://lh3.googleusercontent.com/f-d7nreVZFtpS7d1Fxc6n2RjYeCN1DzXsorep0iv0thslN0akBNk4ATma5FFPK1jnzaQ')
      expect(subject.status).to             eq('updated')
      expect(subject.publisher_email).to    eq('android-support@fb.com')
      expect(subject.description).to        eq('Be together whenever with a simple way to text, video chat and rally the group...')
      expect(subject.price_value).to        be 0
      expect(subject.all_rating).to         be 4.2
      expect(subject.store_url).to          eq('https://play.google.com/store/apps/details?id=com.facebook.orca')
      expect(subject.downloads).to          eq('1,000,000,000+')
      expect(subject.publisher_address).to  eq("1 Hacker Way\nMenlo Park, CA 94025")
      expect(subject.status_unix_timestamp).to eq(1578526140)
      expect(subject.genre).to              eq('Communication')
      expect(subject.privacy_url).to        eq('https://m.facebook.com/policy.php')
      expect(subject.editors_choice).to     be true
      expect(subject.genre_ids).to          include('COMMUNICATION')
      expect(subject.iap_price_range).to    eq('$0.99 - $399.99 per item')
      expect(subject.all_histogram).to      include("1" => 7649347)
      expect(subject.release_date).to       eq('2014-01-30')
      expect(subject.all_rating_count).to   eq(70435991)
      expect(subject.bundle_id).to          eq('com.facebook.orca')
      expect(subject.permissions).to        include('control Near Field Communication')
      expect(subject.status_date).to        eq('January 8, 2020')
      expect(subject.genre_id).to           eq('COMMUNICATION')
    end
  end
end
