module MockMobileDataHelper
  require 'ostruct'

  def mock_sdks
    sdks = Array.new
    200.times do
      sdk_hash = Hash.new
      sdk_hash[:name] =(0...8).map { (65 + rand(26)).chr }.join
      sdk_hash[:website] = '#'
      sdk_hash[:favicon] = '#'
      sdk_hash[:summary] = (0...20).map { (65 + rand(26)).chr }.join
      sdks.push(sdk_hash)
    end
    sdks.map  do |sdk|
      arr = Array.new
      rand(30).times do
        obj = OpenStruct.new
        obj.mightysignal_public_page_link = '#'
        arr.push(obj)
        end
      sdk[:top_200_apps] = arr
      OpenStruct.new(sdk)
    end
  end

  def mock_last_updated
    "2019-02-14 23:59:37"
  end

  def mock_tags
    tags =[
        { id: 2, name: "Monetization", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 33, name: "Ad-Mediation", created_at: "2017-01-11 16:34:58", updated_at: "2017-01-11 16:34:58"},
        { id: 9, name: "Social", created_at:"2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 3, name: "Utilities",created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id:17, name: "Authentication", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 8, name: "Analytics", created_at: "2016-05-26 23:00:19", updated_at:"2016-05-26 23:00:19"},
        { id: 6, name: "App Performance Management", created_at:"2016-05-26 23:00:19", updated_at: "2017-08-16 19:15:25"},
        { id: 7, name: "Backend",created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id:60, name: "1st Party", created_at: "2018-03-21 19:19:16", updated_at: "2018-03-21 19:19:37"},
        { id: 4, name: "Networking", created_at: "2016-05-26 23:00:19",updated_at: "2016-05-26 23:00:19"},
        { id: 23, name: "App Platform", created_at:"2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 24, name: "Ad Attribution", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 14, name: "Infrastructure", created_at: "2016-05-26 23:00:19", updated_at:"2016-05-26 23:00:19"},
        { id: 25, name: "Messaging", created_at: "2016-05-26 23:19:44", updated_at: "2016-05-26 23:19:44"},
        { id: 13, name: "Media", created_at:"2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 47, name: "Video-Chat",created_at: "2017-05-01 23:38:40", updated_at: "2017-05-01 23:38:40"},
        { id:5, name: "UI", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 11, name: "Game Engine", created_at: "2016-05-26 23:00:19", updated_at:"2016-05-26 23:00:19"},
        { id: 18, name: "Deep Linking", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 12, name: "Location", created_at:"2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 19, name: "A/B Testing", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 21, name: "Push", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 38, name: "OCR", created_at: "2017-02-22 23:10:33", updated_at:"2017-02-22 23:10:33"},
        { id: 1, name: "Payments", created_at: "2016-05-26 23:00:19",updated_at: "2016-05-26 23:00:19"},
        { id: 28, name: "Search", created_at: "2016-09-19 19:23:59", updated_at: "2016-09-19 19:23:59"},
        { id: 22, name: "SDK Wrapper",created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id:16, name: "Customer Support", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id: 15, name: "User Engagement", created_at: "2016-05-26 23:00:19",updated_at: "2016-05-26 23:00:19"},
        { id: 51, name: "Security", created_at:"2017-08-31 18:37:38", updated_at: "2017-08-31 18:37:38"},
        { id: 20, name: "Testing",created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        { id:58, name: "User-Feedback", created_at: "2018-02-02 14:48:30", updated_at: "2018-02-02 14:48:30"},
        { id: 41, name: "VoIP", created_at: "2017-02-25 01:02:14", updated_at:"2017-02-25 01:02:14"},
        { id: 35, name: "DMP", created_at: "2017-02-14 23:57:52",updated_at: "2017-02-14 23:57:52"},
        { id: 36, name: "CRM", created_at: "2017-02-14 23:59:37", updated_at: "2017-02-14 23:59:37"}
    ]
    tags.map {|tag| OpenStruct.new(tag) }
  end
  
  def mock_apps
    apps = Array.new
    200.times { apps.push({released_days: rand(100)}) }
    i = 0
    apps.map do |app|
      app[:ranking_change] = rand(-5..5)
      app[:name] = (0...8).map { (65 + rand(26)).chr }.join
      android_developer_name = (0...16).map { (65 + rand(26)).chr }.join
      app[:android_developer] = OpenStruct.new({name: android_developer_name})
      app[:ios_developer] = OpenStruct.new({name: android_developer_name})
      app[:rank] = i += 1
      OpenStruct.new(app)
    end
  end

end