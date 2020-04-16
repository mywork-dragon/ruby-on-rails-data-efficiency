require 'spec_helper'

describe MajorAppHotStoreWriter do
  let(:redis_cli)           { Redis.new(:host => ENV['HOT_STORE_REDIS_URL'], :port => ENV['HOT_STORE_REDIS_PORT']) }
  let(:app_hot_store)       { AppHotStore.new(redis_store: redis_cli) }
  let(:prefix)              { app_hot_store.send(:key, 'app', platform, '*') }

  let!(:relevant_ios_apps) do
    create_list(:ios_app, 2,
      updated_at: Date.today,
      newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date),
      ios_developer: build(:ios_developer)
    ) +
    create_list(:ios_app, 2,
      updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
      newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: Date.today),
      ios_developer: build(:ios_developer)
    )
  end

  let!(:relevant_android_apps) do
    create_list(:android_app, 2,
      updated_at: Date.today,
      newest_android_app_snapshot: create(:android_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date),
      android_developer: build(:android_developer)
    ) +
    create_list(:android_app, 2,
      updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
      newest_android_app_snapshot: create(:android_app_snapshot, updated_at: Date.today),
      android_developer: build(:android_developer)
    )
  end

  before do
    redis_cli.flushall
  end

  context 'incoming recent apps (Charts)' do
    describe '.write_android_major_charts' do
      let(:repeating_app_identifier) { relevant_android_apps.first.app_identifier }

      let!(:android_rankings_free) do
        {
          'total' => 2,
          'apps' => [
            {"created_at"=>Date.yesterday, "platform"=>"android", "country"=>"US", "category"=>"OVERALL", "ranking_type"=>"free", "app_identifier"=>repeating_app_identifier, "rank"=>1},
            {"created_at"=>Date.yesterday, "platform"=>"android", "country"=>"US", "category"=>"OVERALL", "ranking_type"=>"free", "app_identifier"=>relevant_android_apps.second.app_identifier, "rank"=>2}
          ]
        }
      end

      let!(:android_rankings_grossing) do
        {
          'total' => 2,
          'apps' => [
            {"created_at"=>Date.yesterday, "platform"=>"android", "country"=>"US", "category"=>"OVERALL", "ranking_type"=>"grossing", "app_identifier"=>repeating_app_identifier, "rank"=>1},
            {"created_at"=>Date.yesterday, "platform"=>"android", "country"=>"US", "category"=>"OVERALL", "ranking_type"=>"grossing", "app_identifier"=>relevant_android_apps.last.app_identifier, "rank"=>2}
          ]
        }
      end

      before do
        allow(RankingsAccessor).to receive_message_chain(:new, :get_chart).with(hash_including(rank_type: "grossing")) { android_rankings_grossing }
        allow(RankingsAccessor).to receive_message_chain(:new, :get_chart).with(hash_including(rank_type: "free")) { android_rankings_free }
      end

      it 'writes apps to HS w/o repeating' do
        expect(subject).to receive(:_write_app).exactly(3).times
        subject.write_android_major_charts
      end
    end

    describe '.write_ios_major_charts' do
      let(:repeating_app_identifier) { relevant_ios_apps.first.app_identifier }

      let(:ios_rankings_free) do
        {
          'total' => 2,
          'apps' => [
            {"created_at"=>Date.yesterday, "platform"=>"ios", "country"=>"US", "category"=>"36", "ranking_type"=>"free", "app_identifier"=>repeating_app_identifier, "rank"=>1},
            {"created_at"=>Date.yesterday, "platform"=>"ios", "country"=>"US", "category"=>"36", "ranking_type"=>"free", "app_identifier"=>relevant_ios_apps.second.app_identifier, "rank"=>2}
          ]
        }
      end

      let(:ios_rankings_grossing) do
        {
          'total' => 2,
          'apps' => [
            {"created_at"=>Date.yesterday, "platform"=>"ios", "country"=>"US", "category"=>"36", "ranking_type"=>"grossing", "app_identifier"=>repeating_app_identifier, "rank"=>1},
            {"created_at"=>Date.yesterday, "platform"=>"ios", "country"=>"US", "category"=>"36", "ranking_type"=>"grossing", "app_identifier"=>relevant_ios_apps.last.app_identifier, "rank"=>2}
          ]
        }
      end

      before do
        allow(RankingsAccessor).to receive_message_chain(:new, :get_chart).with(hash_including(rank_type: "grossing")) { ios_rankings_grossing }
        allow(RankingsAccessor).to receive_message_chain(:new, :get_chart).with(hash_including(rank_type: "free")) { ios_rankings_free }
      end

      it 'writes apps to HS w/o repeating' do
        expect(subject).to receive(:_write_app).exactly(3).times
        subject.write_ios_major_charts
      end
    end
  end


  context 'existent apps in varys db' do

    let!(:tag) { create(:tag, name: tag_name) }

    before do
      # Not relevant apps. These apps where created and updated before relevance date.
      tag.android_apps << create_list(:android_app, 2,
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_android_app_snapshot: create(:android_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date),
        android_developer: build(:android_developer)
      )

      tag.ios_apps << create_list(:ios_app, 2,
        updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date,
        newest_ios_app_snapshot: create(:ios_app_snapshot, updated_at: (HotStore::TIME_OF_RELEVANCE - 2.days).to_date),
        ios_developer: build(:ios_developer)
      )

      tag.android_apps << relevant_android_apps
      tag.ios_apps << relevant_ios_apps

      tag.android_developers << tag.android_apps.map(&:android_developer)
      tag.ios_developers << tag.ios_apps.map(&:ios_developer)
    end


    context 'Tags' do
      let(:call_method) { subject.send(method) }

      context 'Major App' do

        let(:tag_name) { 'Major App' }
        let(:method)   { :write_major_app_tag }

        context 'android' do
          let(:platform) { 'android' }
          it 'writes only relevant apps' do
            call_method

            expect(redis_cli.keys(prefix).size).to eq relevant_android_apps.size

            AndroidApp
              .relevant_since(HotStore::TIME_OF_RELEVANCE)
              .map { |app| assert(platform, app) }

          end

          xit 'sends alarm when too few apps'
        end

        context 'for ios' do
          let(:platform) { 'ios' }
          it 'writes only relevant apps' do
            call_method

            expect(redis_cli.keys(prefix).size).to eq relevant_ios_apps.size

            IosApp
              .relevant_since(HotStore::TIME_OF_RELEVANCE)
              .map { |app| assert(platform, app) }
          end

          xit 'sends alarm when too few apps'
        end
      end


      context 'Major Publisher' do
        let(:tag_name) { 'Major Publisher' }
        let(:method)   { :write_major_publisher_tag }

        context 'android' do
          let(:platform) { 'android' }

          it 'writes only relevant apps' do
            call_method

            expect(redis_cli.keys(prefix).size).to eq relevant_android_apps.size

            AndroidApp
              .relevant_since(HotStore::TIME_OF_RELEVANCE)
              .map { |app| assert(platform, app) }
          end

        end

        context 'ios' do
          let(:platform) { 'ios' }

          it 'writes only relevant apps' do
            call_method

            expect(redis_cli.keys(prefix).size).to eq relevant_ios_apps.size

            IosApp
              .relevant_since(HotStore::TIME_OF_RELEVANCE)
              .map { |app| assert(platform, app) }
          end
        end
      end

      def assert(platform, app)
        expect(app_hot_store.read(platform, app.id)).to include(matcher(platform, app))
      end

      def matcher(platform, app)
        {
          "major_app"         => true,
          "id"                => app.id,
          "platform"          => platform,
          "app_identifier"    => app.app_identifier
        }
      end
    end


  end

end
