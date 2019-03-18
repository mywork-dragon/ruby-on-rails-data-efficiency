module MockMobileDataHelper
  require 'ostruct'
  require "time"
  require 'json'

  def mock_sdks
    sdks = Array.new
    200.times do
      sdk_hash = Hash.new
      sdk_hash[:name] = (0...8).map {(65 + rand(26)).chr}.join
      sdk_hash[:website] = '#'
      sdk_hash[:favicon] = '#'
      sdk_hash[:summary] = (0...20).map {(65 + rand(26)).chr}.join
      sdks.push(sdk_hash)
    end
    sdks.map do |sdk|
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

  def mock_search_apps
    [{
         "name": "UberFacts",
         "icon": "//lh5.ggpht.com/QbU-o9B3OJ_-uF8tsY5GNv2sZ-asvhkbWAXe-q-mgAiNQaUu3e7L6zOFgM_C6im8Fg=w300",
         "platform": "android",
         "app_identifier": "com.uberfacts.uf",
         "publisher": "Uber Unlimited LLC"
     },
     {
         "name": "Uber",
         "icon": "https://lh3.googleusercontent.com/nTcQY6kRL6TgNQu4NSG0eBLQGDTTVj2-YOVyA71LFOuePtx057oSmt_xiObOrKdXMlg=s180",
         "platform": "android",
         "app_identifier": "com.ubercab",
         "publisher": "Uber Technologies, Inc."
     },
     {
         "name": "Uber",
         "icon": "https://is5-ssl.mzstatic.com/image/thumb/Purple124/v4/03/97/45/03974578-2604-85a9-96ea-7e8b3b208c67/source/100x100bb.jpg",
         "platform": "ios",
         "app_identifier": 368677368,
         "publisher": "Uber Technologies, Inc."
     },
     {
         "name": "UberConference - Conferencing",
         "icon": "https://lh3.googleusercontent.com/7Yo2ViA3Okh3Ob-BDQYr5deb4nKv7yMbzYLHjZEME9fQT0sS2TbHU-QJy50iOO5s6A=s180",
         "platform": "android",
         "app_identifier": "com.uberconference",
         "publisher": "Switch Communications, Inc"
     },
     {
         "name": "UberGenPass",
         "icon": "https://is2-ssl.mzstatic.com/image/thumb/Purple3/v4/91/8f/c6/918fc674-18e0-912f-8dd5-e58489116126/source/100x100bb.jpg",
         "platform": "ios",
         "app_identifier": 588224057,
         "publisher": "Camazotz Limited"
     },
     {
         "name": "UberFocus",
         "icon": "https://is2-ssl.mzstatic.com/image/thumb/Purple5/v4/d5/b1/e3/d5b1e31e-bbc8-c933-c455-c96453d0d67b/source/100x100bb.jpg",
         "platform": "ios",
         "app_identifier": 830514912,
         "publisher": "mobix e.K."
     },
     {
         "name": "UberDate",
         "icon": "https://is4-ssl.mzstatic.com/image/thumb/Purple3/v4/1d/e2/26/1de22674-bb45-6110-7aa4-850ec3856f02/source/100x100bb.jpg",
         "platform": "ios",
         "app_identifier": 979662286,
         "publisher": "heidi hughes"
     },
     {
         "name": "UberConference",
         "icon": "https://is2-ssl.mzstatic.com/image/thumb/Purple124/v4/1b/45/21/1b4521e9-475e-2f64-003f-2daf640fc4a5/source/100x100bb.jpg",
         "platform": "ios",
         "app_identifier": 579106114,
         "publisher": "Dialpad, Inc."
     },
     {
         "name": "UberDate",
         "icon": "https://lh3.ggpht.com/G6XsR1XHF4y1EIOqj67o7KUXb5nN8eOpArsm0n_n3k8LKK_uF9t2eUFyrK7_ODCnQ94=s180",
         "platform": "android",
         "app_identifier": "com.jingged.uberdate",
         "publisher": "Uberdate"
     },
     {
         "name": "UberMarche",
         "icon": "https://is1-ssl.mzstatic.com/image/thumb/Purple128/v4/20/ba/4a/20ba4a84-97f2-6118-1038-c9d593c7e6a5/source/100x100bb.jpg",
         "platform": "ios",
         "app_identifier": 1436036010,
         "publisher": "Bjorn Ivesdal"
     }]
  end

  def mock_tags
    tags = [
        {id: 2, name: "Monetization", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 33, name: "Ad-Mediation", created_at: "2017-01-11 16:34:58", updated_at: "2017-01-11 16:34:58"},
        {id: 9, name: "Social", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 3, name: "Utilities", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 17, name: "Authentication", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 8, name: "Analytics", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 6, name: "App Performance Management", created_at: "2016-05-26 23:00:19", updated_at: "2017-08-16 19:15:25"},
        {id: 7, name: "Backend", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 60, name: "1st Party", created_at: "2018-03-21 19:19:16", updated_at: "2018-03-21 19:19:37"},
        {id: 4, name: "Networking", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 23, name: "App Platform", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 24, name: "Ad Attribution", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 14, name: "Infrastructure", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 25, name: "Messaging", created_at: "2016-05-26 23:19:44", updated_at: "2016-05-26 23:19:44"},
        {id: 13, name: "Media", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 47, name: "Video-Chat", created_at: "2017-05-01 23:38:40", updated_at: "2017-05-01 23:38:40"},
        {id: 5, name: "UI", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 11, name: "Game Engine", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 18, name: "Deep Linking", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 12, name: "Location", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 19, name: "A/B Testing", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 21, name: "Push", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 38, name: "OCR", created_at: "2017-02-22 23:10:33", updated_at: "2017-02-22 23:10:33"},
        {id: 1, name: "Payments", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 28, name: "Search", created_at: "2016-09-19 19:23:59", updated_at: "2016-09-19 19:23:59"},
        {id: 22, name: "SDK Wrapper", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 16, name: "Customer Support", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 15, name: "User Engagement", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 51, name: "Security", created_at: "2017-08-31 18:37:38", updated_at: "2017-08-31 18:37:38"},
        {id: 20, name: "Testing", created_at: "2016-05-26 23:00:19", updated_at: "2016-05-26 23:00:19"},
        {id: 58, name: "User-Feedback", created_at: "2018-02-02 14:48:30", updated_at: "2018-02-02 14:48:30"},
        {id: 41, name: "VoIP", created_at: "2017-02-25 01:02:14", updated_at: "2017-02-25 01:02:14"},
        {id: 35, name: "DMP", created_at: "2017-02-14 23:57:52", updated_at: "2017-02-14 23:57:52"},
        {id: 36, name: "CRM", created_at: "2017-02-14 23:59:37", updated_at: "2017-02-14 23:59:37"}
    ]
    tags.map {|tag| OpenStruct.new(tag)}
  end

  def mock_apps
    apps = Array.new
    200.times {apps.push({released_days: rand(100)})}
    i = 0
    apps.map do |app|
      app[:ranking_change] = rand(-5..5)
      app[:name] = (0...8).map {(65 + rand(26)).chr}.join
      android_developer_name = (0...16).map {(65 + rand(26)).chr}.join
      app[:android_developer] = OpenStruct.new({name: android_developer_name})
      app[:ios_developer] = OpenStruct.new({name: android_developer_name})
      app[:rank] = i += 1
      OpenStruct.new(app)
    end
  end

  def mock_batches_by_week
    week1 = [
        {id: 8504586, owner_id: 2284350, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:46", updated_at: "2019-03-06 18:30:46"},
        {id: 8492542, owner_id: 1054733, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-03-04", created_at: "2019-03-04 18:30:36", updated_at: "2019-03-04 18:30:36"},
        {id: 8504602, owner_id: 4193069, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:48", updated_at: "2019-03-06 18:30:48"},
        {id: 8504596, owner_id: 843021, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:47", updated_at: "2019-03-06 18:30:47"},
        {id: 8504592, owner_id: 1098019, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:47", updated_at: "2019-03-06 18:30:47"},
        {id: 8504582, owner_id: 4193530, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:46", updated_at: "2019-03-06 18:30:46"},
        {id: 8504598, owner_id: 3914489, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:48", updated_at: "2019-03-06 18:30:48"},
        {id: 8496312, owner_id: 719954, owner_type: "IosApp", activity_type: 0, activities_count: 3, week: "2019-03-04", created_at: "2019-03-05 18:10:33", updated_at: "2019-03-05 18:10:33"},
        {id: 8504588, owner_id: 1041341, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:47", updated_at: "2019-03-06 18:30:47"},
        {id: 8504584, owner_id: 4217015, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:46", updated_at: "2019-03-06 18:30:46"},
        {id: 8504594, owner_id: 334431, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:47", updated_at: "2019-03-06 18:30:47"},
        {id: 8504600, owner_id: 333106, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:48", updated_at: "2019-03-06 18:30:48"},
        {id: 8496447, owner_id: 301060, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-03-04", created_at: "2019-03-05 18:30:34", updated_at: "2019-03-05 18:30:34"},
        {id: 8492548, owner_id: 4270396, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-03-04", created_at: "2019-03-04 18:30:36", updated_at: "2019-03-04 18:30:36"},
        {id: 8504590, owner_id: 2789262, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 18:30:47", updated_at: "2019-03-06 18:30:47"},
        {id: 8499764, owner_id: 6278778, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 03:13:46", updated_at: "2019-03-06 03:13:46"},
        {id: 8501904, owner_id: 7020044, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 09:34:02", updated_at: "2019-03-06 09:34:02"},
        {id: 8501851, owner_id: 7009567, owner_type: "AndroidApp", activity_type: 0, activities_count: 7, week: "2019-03-04", created_at: "2019-03-06 09:25:38", updated_at: "2019-03-06 09:25:38"},
        {id: 8507944, owner_id: 7391947, owner_type: "AndroidApp", activity_type: 0, activities_count: 32, week: "2019-03-04", created_at: "2019-03-06 22:06:52", updated_at: "2019-03-06 22:06:52"},
        {id: 8493005, owner_id: 61556, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-03-04", created_at: "2019-03-05 10:29:28", updated_at: "2019-03-05 10:29:28"},
        {id: 8494726, owner_id: 1855256, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-03-04", created_at: "2019-03-05 14:36:29", updated_at: "2019-03-05 14:36:29"},
        {id: 8492637, owner_id: 419, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-03-04", created_at: "2019-03-05 10:01:16", updated_at: "2019-03-05 10:01:16"},
        {id: 8498765, owner_id: 5502450, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-03-04", created_at: "2019-03-05 23:38:35", updated_at: "2019-03-05 23:38:35"},
        {id: 8503806, owner_id: 7302921, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-03-04", created_at: "2019-03-06 14:38:32", updated_at: "2019-03-06 14:38:32"},
        {id: 8493740, owner_id: 398458, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-03-04", created_at: "2019-03-05 11:48:09", updated_at: "2019-03-05 11:48:09"},
        {id: 8502180, owner_id: 7076532, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-03-04", created_at: "2019-03-06 10:32:43", updated_at: "2019-03-06 10:32:43"}
    ]
    week2 = [
        {id: 8473414, owner_id: 3754071, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 18:30:45", updated_at: "2019-03-01 18:30:45"},
        {id: 8492399, owner_id: 3260245, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-25", created_at: "2019-03-03 18:30:57", updated_at: "2019-03-03 18:30:57"},
        {id: 8502239, owner_id: 3804709, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-25", created_at: "2019-03-06 10:38:12", updated_at: "2019-03-06 10:38:12"},
        {id: 8473410, owner_id: 3976072, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 18:30:44", updated_at: "2019-03-01 18:30:44"},
        {id: 8508714, owner_id: 4157804, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 21, week: "2019-02-25", created_at: "2019-03-06 22:59:33", updated_at: "2019-03-06 22:59:33"},
        {id: 8483063, owner_id: 4282620, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-02-25", created_at: "2019-03-02 18:30:44", updated_at: "2019-03-02 18:30:44"},
        {id: 8473404, owner_id: 4204897, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 18:30:43", updated_at: "2019-03-01 18:30:43"},
        {id: 8468416, owner_id: 4213404, owner_type: "IosApp", activity_type: 0, activities_count: 39, week: "2019-02-25", created_at: "2019-02-28 03:37:02", updated_at: "2019-02-28 03:37:02"},
        {id: 8492298, owner_id: 4226324, owner_type: "IosApp", activity_type: 0, activities_count: 31, week: "2019-02-25", created_at: "2019-03-03 14:01:53", updated_at: "2019-03-03 14:01:53"},
        {id: 8492389, owner_id: 4264553, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-25", created_at: "2019-03-03 18:30:55", updated_at: "2019-03-03 18:30:55"},
        {id: 8469042, owner_id: 4273937, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-25", created_at: "2019-02-28 18:30:27", updated_at: "2019-02-28 18:30:27"},
        {id: 8483069, owner_id: 4275172, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-25", created_at: "2019-03-02 18:30:44", updated_at: "2019-03-02 18:30:44"},
        {id: 8492403, owner_id: 2689331, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-25", created_at: "2019-03-03 18:30:57", updated_at: "2019-03-03 18:30:57"},
        {id: 8460430, owner_id: 4246488, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-25", created_at: "2019-02-26 18:30:48", updated_at: "2019-02-26 18:30:48"},
        {id: 8483073, owner_id: 1598976, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-25", created_at: "2019-03-02 18:30:45", updated_at: "2019-03-02 18:30:45"},
        {id: 8492385, owner_id: 1621599, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-25", created_at: "2019-03-03 18:30:55", updated_at: "2019-03-03 18:30:55"},
        {id: 8448203, owner_id: 620260, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-25", created_at: "2019-02-25 18:30:32", updated_at: "2019-02-25 18:30:32"},
        {id: 8502756, owner_id: 211124, owner_type: "IosApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-06 11:43:19", updated_at: "2019-03-06 11:43:19"},
        {id: 8476958, owner_id: 5213470, owner_type: "AndroidApp", activity_type: 0, activities_count: 9, week: "2019-02-25", created_at: "2019-03-02 01:04:45", updated_at: "2019-03-02 01:04:45"},
        {id: 8475630, owner_id: 4600396, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 23:01:15", updated_at: "2019-03-01 23:01:15"},
        {id: 8477947, owner_id: 5783765, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-02 03:18:28", updated_at: "2019-03-02 03:18:28"},
        {id: 8475603, owner_id: 4581779, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 22:59:24", updated_at: "2019-03-01 22:59:24"},
        {id: 8460072, owner_id: 3587266, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-02-26 17:22:40", updated_at: "2019-02-26 17:22:40"},
        {id: 8444228, owner_id: 7211467, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-02-25 10:18:38", updated_at: "2019-02-25 10:18:38"},
        {id: 8472247, owner_id: 2288960, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-03-01 16:02:59", updated_at: "2019-03-01 16:02:59"},
        {id: 8458711, owner_id: 1869431, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-02-26 13:53:46", updated_at: "2019-02-26 13:53:46"},
        {id: 8471595, owner_id: 1648392, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-25", created_at: "2019-03-01 14:44:01", updated_at: "2019-03-01 14:44:01"},
        {id: 8473155, owner_id: 2988198, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-03-01 17:48:32", updated_at: "2019-03-01 17:48:32"},
        {id: 8457804, owner_id: 413876, owner_type: "AndroidApp", activity_type: 0, activities_count: 6, week: "2019-02-25", created_at: "2019-02-26 12:01:50", updated_at: "2019-02-26 12:01:50"},
        {id: 8448499, owner_id: 7363256, owner_type: "AndroidApp", activity_type: 0, activities_count: 16, week: "2019-02-25", created_at: "2019-02-25 18:42:20", updated_at: "2019-02-25 18:42:20"},
        {id: 8479368, owner_id: 6465590, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-03-02 06:42:49", updated_at: "2019-03-02 06:42:49"},
        {id: 8443399, owner_id: 7361202, owner_type: "AndroidApp", activity_type: 0, activities_count: 58, week: "2019-02-25", created_at: "2019-02-25 08:17:55", updated_at: "2019-02-25 08:17:55"},
        {id: 8445684, owner_id: 7332597, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-02-25 14:21:34", updated_at: "2019-02-25 14:21:34"},
        {id: 8482566, owner_id: 7294606, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-02 16:21:52", updated_at: "2019-03-02 16:21:52"},
        {id: 8482446, owner_id: 7278088, owner_type: "AndroidApp", activity_type: 0, activities_count: 27, week: "2019-02-25", created_at: "2019-03-02 15:58:09", updated_at: "2019-03-02 15:58:09"},
        {id: 8482214, owner_id: 7255922, owner_type: "AndroidApp", activity_type: 0, activities_count: 44, week: "2019-02-25", created_at: "2019-03-02 15:26:28", updated_at: "2019-03-02 15:26:28"},
        {id: 8482029, owner_id: 7228732, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-02 14:53:20", updated_at: "2019-03-02 14:53:20"},
        {id: 8464375, owner_id: 7216947, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-25", created_at: "2019-02-27 08:46:04", updated_at: "2019-02-27 08:46:04"},
        {id: 8444085, owner_id: 7193264, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-02-25 09:57:17", updated_at: "2019-02-25 09:57:17"},
        {id: 8481699, owner_id: 7160965, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-02 13:45:36", updated_at: "2019-03-02 13:45:36"},
        {id: 8481595, owner_id: 7133519, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-25", created_at: "2019-03-02 13:15:27", updated_at: "2019-03-02 13:15:27"},
        {id: 8492256, owner_id: 7109448, owner_type: "AndroidApp", activity_type: 0, activities_count: 28, week: "2019-02-25", created_at: "2019-03-03 11:58:09", updated_at: "2019-03-03 11:58:09"},
        {id: 8463597, owner_id: 6870916, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-02-27 05:04:39", updated_at: "2019-02-27 05:04:39"},
        {id: 8463404, owner_id: 6782187, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-02-27 04:16:37", updated_at: "2019-02-27 04:16:37"},
        {id: 8463080, owner_id: 6592187, owner_type: "AndroidApp", activity_type: 0, activities_count: 22, week: "2019-02-25", created_at: "2019-02-27 02:57:04", updated_at: "2019-02-27 02:57:04"},
        {id: 8479672, owner_id: 6554346, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-02 07:19:08", updated_at: "2019-03-02 07:19:08"},
        {id: 8470161, owner_id: 135881, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-03-01 11:57:31", updated_at: "2019-03-01 11:57:31"},
        {id: 8469362, owner_id: 42, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 10:15:33", updated_at: "2019-03-01 10:15:33"},
        {id: 8469430, owner_id: 4203, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 10:28:48", updated_at: "2019-03-01 10:28:48"},
        {id: 8457069, owner_id: 2040, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-02-26 10:35:25", updated_at: "2019-02-26 10:35:25"},
        {id: 8469552, owner_id: 37634, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 10:47:01", updated_at: "2019-03-01 10:47:01"},
        {id: 8469465, owner_id: 10268, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-03-01 10:34:06", updated_at: "2019-03-01 10:34:06"},
        {id: 8469662, owner_id: 61925, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-03-01 10:59:27", updated_at: "2019-03-01 10:59:27"},
        {id: 8457110, owner_id: 12342, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-02-26 10:40:21", updated_at: "2019-02-26 10:40:21"},
        {id: 8457105, owner_id: 11272, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-02-26 10:39:46", updated_at: "2019-02-26 10:39:46"},
        {id: 8469517, owner_id: 26367, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 10:42:37", updated_at: "2019-03-01 10:42:37"},
        {id: 8469412, owner_id: 2886, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 10:25:31", updated_at: "2019-03-01 10:25:31"},
        {id: 8469372, owner_id: 281, owner_type: "AndroidApp", activity_type: 0, activities_count: 4, week: "2019-02-25", created_at: "2019-03-01 10:17:32", updated_at: "2019-03-01 10:17:32"},
        {id: 8457044, owner_id: 409, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-02-26 10:32:16", updated_at: "2019-02-26 10:32:16"},
        {id: 8469381, owner_id: 602, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-25", created_at: "2019-03-01 10:18:50", updated_at: "2019-03-01 10:18:50"},
        {id: 8469385, owner_id: 739, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-25", created_at: "2019-03-01 10:19:26", updated_at: "2019-03-01 10:19:26"}
    ]
    week3 = [
        {id: 8388706, owner_id: 3938782, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-18", created_at: "2019-02-18 18:30:29", updated_at: "2019-02-18 18:30:29"},
        {id: 8389162, owner_id: 4249151, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-18", created_at: "2019-02-19 18:31:30", updated_at: "2019-02-19 18:31:30"},
        {id: 8423922, owner_id: 3984593, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 18:30:52", updated_at: "2019-02-23 18:30:52"},
        {id: 8389170, owner_id: 4157804, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-02-18", created_at: "2019-02-19 18:31:31", updated_at: "2019-02-19 18:31:31"},
        {id: 8502821, owner_id: 719954, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 3, week: "2019-02-18", created_at: "2019-03-06 11:54:46", updated_at: "2019-03-06 11:54:46"},
        {id: 8389160, owner_id: 333106, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-02-18", created_at: "2019-02-19 18:31:30", updated_at: "2019-02-19 18:31:30"},
        {id: 8401505, owner_id: 1598976, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 18:30:57", updated_at: "2019-02-20 18:30:57"},
        {id: 8389156, owner_id: 1621599, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-18", created_at: "2019-02-19 18:31:29", updated_at: "2019-02-19 18:31:29"},
        {id: 8423217, owner_id: 51795, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-18", created_at: "2019-02-22 18:30:47", updated_at: "2019-02-22 18:30:47"},
        {id: 8438944, owner_id: 2760187, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-18", created_at: "2019-02-24 18:30:39", updated_at: "2019-02-24 18:30:39"},
        {id: 8453801, owner_id: 4115196, owner_type: "IosApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-25 22:37:24", updated_at: "2019-02-25 22:37:24"},
        {id: 8404098, owner_id: 6065515, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-18", created_at: "2019-02-21 00:41:10", updated_at: "2019-02-21 00:41:10"},
        {id: 8424076, owner_id: 14799, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 19:33:08", updated_at: "2019-02-23 19:33:08"},
        {id: 8406445, owner_id: 6799484, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-21 06:14:16", updated_at: "2019-02-21 06:14:16"},
        {id: 8441813, owner_id: 6769672, owner_type: "AndroidApp", activity_type: 0, activities_count: 9, week: "2019-02-18", created_at: "2019-02-25 03:12:57", updated_at: "2019-02-25 03:12:57"},
        {id: 8406257, owner_id: 6760817, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-21 05:46:09", updated_at: "2019-02-21 05:46:09"},
        {id: 8424026, owner_id: 4395, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-18", created_at: "2019-02-23 19:26:05", updated_at: "2019-02-23 19:26:05"},
        {id: 8389406, owner_id: 4572, owner_type: "AndroidApp", activity_type: 0, activities_count: 4, week: "2019-02-18", created_at: "2019-02-20 00:51:31", updated_at: "2019-02-20 00:51:31"},
        {id: 8404757, owner_id: 6329240, owner_type: "AndroidApp", activity_type: 0, activities_count: 8, week: "2019-02-18", created_at: "2019-02-21 02:16:44", updated_at: "2019-02-21 02:16:44"},
        {id: 8404292, owner_id: 6139289, owner_type: "AndroidApp", activity_type: 0, activities_count: 10, week: "2019-02-18", created_at: "2019-02-21 01:05:32", updated_at: "2019-02-21 01:05:32"},
        {id: 8424021, owner_id: 3779, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 19:24:37", updated_at: "2019-02-23 19:24:37"},
        {id: 8407415, owner_id: 7009567, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-18", created_at: "2019-02-21 09:06:54", updated_at: "2019-02-21 09:06:54"},
        {id: 8423161, owner_id: 49, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-22 17:16:04", updated_at: "2019-02-22 17:16:04"},
        {id: 8389251, owner_id: 124, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-18", created_at: "2019-02-20 00:40:09", updated_at: "2019-02-20 00:40:09"},
        {id: 8401887, owner_id: 7259013, owner_type: "AndroidApp", activity_type: 0, activities_count: 18, week: "2019-02-18", created_at: "2019-02-20 19:03:29", updated_at: "2019-02-20 19:03:29"},
        {id: 8425937, owner_id: 692984, owner_type: "AndroidApp", activity_type: 0, activities_count: 12, week: "2019-02-18", created_at: "2019-02-23 22:54:38", updated_at: "2019-02-23 22:54:38"},
        {id: 8423979, owner_id: 892, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 19:17:48", updated_at: "2019-02-23 19:17:48"},
        {id: 8423980, owner_id: 1064, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-18", created_at: "2019-02-23 19:17:51", updated_at: "2019-02-23 19:17:51"},
        {id: 8408076, owner_id: 7144648, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-21 11:46:43", updated_at: "2019-02-21 11:46:43"},
        {id: 8423974, owner_id: 1097, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-18", created_at: "2019-02-23 19:17:25", updated_at: "2019-02-23 19:17:25"},
        {id: 8423987, owner_id: 1109, owner_type: "AndroidApp", activity_type: 0, activities_count: 4, week: "2019-02-18", created_at: "2019-02-23 19:19:19", updated_at: "2019-02-23 19:19:19"},
        {id: 8407853, owner_id: 7102075, owner_type: "AndroidApp", activity_type: 0, activities_count: 5, week: "2019-02-18", created_at: "2019-02-21 10:50:53", updated_at: "2019-02-21 10:50:53"},
        {id: 8389309, owner_id: 1366, owner_type: "AndroidApp", activity_type: 0, activities_count: 24, week: "2019-02-18", created_at: "2019-02-20 00:46:05", updated_at: "2019-02-20 00:46:05"},
        {id: 8442947, owner_id: 7034851, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-25 06:53:59", updated_at: "2019-02-25 06:53:59"},
        {id: 8423999, owner_id: 1837, owner_type: "AndroidApp", activity_type: 0, activities_count: 4, week: "2019-02-18", created_at: "2019-02-23 19:19:55", updated_at: "2019-02-23 19:19:55"},
        {id: 8437932, owner_id: 5032940, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-24 16:24:17", updated_at: "2019-02-24 16:24:17"},
        {id: 8437886, owner_id: 5003506, owner_type: "AndroidApp", activity_type: 0, activities_count: 8, week: "2019-02-18", created_at: "2019-02-24 16:18:51", updated_at: "2019-02-24 16:18:51"},
        {id: 8397586, owner_id: 3211259, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 12:23:34", updated_at: "2019-02-20 12:23:34"},
        {id: 8389673, owner_id: 46800, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 01:14:59", updated_at: "2019-02-20 01:14:59"},
        {id: 8425042, owner_id: 282720, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 21:15:59", updated_at: "2019-02-23 21:15:59"},
        {id: 8425132, owner_id: 299480, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 21:24:22", updated_at: "2019-02-23 21:24:22"},
        {id: 8390423, owner_id: 299505, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 02:44:55", updated_at: "2019-02-20 02:44:55"},
        {id: 8432261, owner_id: 2575700, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-18", created_at: "2019-02-24 07:25:07", updated_at: "2019-02-24 07:25:07"},
        {id: 8431544, owner_id: 2421223, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-18", created_at: "2019-02-24 06:27:48", updated_at: "2019-02-24 06:27:48"},
        {id: 8394858, owner_id: 2403430, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 08:31:52", updated_at: "2019-02-20 08:31:52"},
        {id: 8424296, owner_id: 69232, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 19:59:09", updated_at: "2019-02-23 19:59:09"},
        {id: 8389756, owner_id: 61925, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 01:20:36", updated_at: "2019-02-20 01:20:36"},
        {id: 8399006, owner_id: 3698394, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 14:46:32", updated_at: "2019-02-20 14:46:32"},
        {id: 8426129, owner_id: 775077, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 23:15:55", updated_at: "2019-02-23 23:15:55"},
        {id: 8426789, owner_id: 1177406, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-24 00:43:50", updated_at: "2019-02-24 00:43:50"},
        {id: 8401756, owner_id: 4991338, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 18:54:59", updated_at: "2019-02-20 18:54:59"},
        {id: 8424684, owner_id: 173842, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-23 20:45:31", updated_at: "2019-02-23 20:45:31"},
        {id: 8437031, owner_id: 4599685, owner_type: "AndroidApp", activity_type: 0, activities_count: 5, week: "2019-02-18", created_at: "2019-02-24 15:02:07", updated_at: "2019-02-24 15:02:07"},
        {id: 8436865, owner_id: 4509417, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-24 14:48:51", updated_at: "2019-02-24 14:48:51"},
        {id: 8400602, owner_id: 4449449, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-18", created_at: "2019-02-20 17:21:23", updated_at: "2019-02-20 17:21:23"},
        {id: 8400477, owner_id: 4384798, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-18", created_at: "2019-02-20 17:12:21", updated_at: "2019-02-20 17:12:21"},
        {id: 8436470, owner_id: 4280158, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-18", created_at: "2019-02-24 14:05:02", updated_at: "2019-02-24 14:05:02"}
    ]
    week4 = [
        {id: 8423231, owner_id: 4231689, owner_type: "IosApp", activity_type: 'install', activities_count: 53, week: "2019-02-11", created_at: "2019-02-22 18:31:10", updated_at: "2019-02-22 18:31:10"},
        {id: 8399462, owner_id: 477967, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-11", created_at: "2019-02-20 15:46:09", updated_at: "2019-02-20 15:46:09"},
        {id: 8395536, owner_id: 216548, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-11", created_at: "2019-02-20 09:09:55", updated_at: "2019-02-20 09:09:55"},
        {id: 8334566, owner_id: 4264556, owner_type: "IosApp", activity_type: 'install', activities_count: 1, week: "2019-02-11", created_at: "2019-02-11 18:36:25", updated_at: "2019-02-11 18:36:25"},
        {id: 8334626, owner_id: 4264556, owner_type: "IosApp", activity_type: 'install', activities_count: 41, week: "2019-02-11", created_at: "2019-02-11 23:14:16", updated_at: "2019-02-11 23:14:16"},
        {id: 8361357, owner_id: 150342, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-02-11", created_at: "2019-02-14 18:30:40", updated_at: "2019-02-14 18:30:40"},
        {id: 8348685, owner_id: 2760187, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-02-11", created_at: "2019-02-13 18:33:33", updated_at: "2019-02-13 18:33:33"},
        {id: 8367531, owner_id: 4202307, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 1, week: "2019-02-11", created_at: "2019-02-15 18:30:35", updated_at: "2019-02-15 18:30:35"},
        {id: 8403035, owner_id: 809936, owner_type: "IosApp", activity_type: 'entered_top_apps', activities_count: 9, week: "2019-02-11", created_at: "2019-02-20 22:01:51", updated_at: "2019-02-20 22:01:51"},
        {id: 8422884, owner_id: 2789262, owner_type: "IosApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-22 12:11:54", updated_at: "2019-02-22 12:11:54"},
        {id: 8388694, owner_id: 3260245, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-11", created_at: "2019-02-17 18:30:38", updated_at: "2019-02-17 18:30:38"},
        {id: 8500936, owner_id: 3503900, owner_type: "IosApp", activity_type: 0, activities_count: 3, week: "2019-02-11", created_at: "2019-03-06 06:27:30", updated_at: "2019-03-06 06:27:30"},
        {id: 8334574, owner_id: 3879140, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-11", created_at: "2019-02-11 18:36:26", updated_at: "2019-02-11 18:36:26"},
        {id: 8342836, owner_id: 3914489, owner_type: "IosApp", activity_type: 0, activities_count: 2, week: "2019-02-11", created_at: "2019-02-12 23:15:32", updated_at: "2019-02-12 23:15:32"},
        {id: 8405649, owner_id: 1329310, owner_type: "IosApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-21 04:30:26", updated_at: "2019-02-21 04:30:26"},
        {id: 8361371, owner_id: 892915, owner_type: "IosApp", activity_type: 3, activities_count: 1, week: "2019-02-11", created_at: "2019-02-14 18:30:41", updated_at: "2019-02-14 18:30:41"},
        {id: 8445942, owner_id: 4043522, owner_type: "IosApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-25 15:33:21", updated_at: "2019-02-25 15:33:21"},
        {id: 8510442, owner_id: 891489, owner_type: "IosApp", activity_type: 0, activities_count: 2, week: "2019-02-11", created_at: "2019-03-07 00:00:34", updated_at: "2019-03-07 00:00:34"},
        {id: 8423194, owner_id: 4190510, owner_type: "IosApp", activity_type: 0, activities_count: 4, week: "2019-02-11", created_at: "2019-02-22 18:00:13", updated_at: "2019-02-22 18:00:13"},
        {id: 8439244, owner_id: 847275, owner_type: "IosApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-24 19:19:16", updated_at: "2019-02-24 19:19:16"},
        {id: 8492206, owner_id: 843021, owner_type: "IosApp", activity_type: 0, activities_count: 2, week: "2019-02-11", created_at: "2019-03-03 10:07:43", updated_at: "2019-03-03 10:07:43"},
        {id: 8408737, owner_id: 4193199, owner_type: "IosApp", activity_type: 0, activities_count: 36, week: "2019-02-11", created_at: "2019-02-21 14:12:30", updated_at: "2019-02-21 14:12:30"},
        {id: 8361691, owner_id: 126, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-15 09:34:22", updated_at: "2019-02-15 09:34:22"},
        {id: 8361458, owner_id: 7275444, owner_type: "AndroidApp", activity_type: 0, activities_count: 29, week: "2019-02-11", created_at: "2019-02-14 21:40:11", updated_at: "2019-02-14 21:40:11"},
        {id: 8335213, owner_id: 68332, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-12 10:06:11", updated_at: "2019-02-12 10:06:11"},
        {id: 8362884, owner_id: 413875, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-11", created_at: "2019-02-15 11:47:40", updated_at: "2019-02-15 11:47:40"},
        {id: 8361701, owner_id: 739, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-15 09:36:30", updated_at: "2019-02-15 09:36:30"},
        {id: 8362033, owner_id: 84033, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-15 10:17:26", updated_at: "2019-02-15 10:17:26"},
        {id: 8352771, owner_id: 7323902, owner_type: "AndroidApp", activity_type: 0, activities_count: 44, week: "2019-02-11", created_at: "2019-02-14 05:45:35", updated_at: "2019-02-14 05:45:35"},
        {id: 8335395, owner_id: 141816, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-11", created_at: "2019-02-12 10:31:33", updated_at: "2019-02-12 10:31:33"},
        {id: 8381852, owner_id: 7336604, owner_type: "AndroidApp", activity_type: 0, activities_count: 27, week: "2019-02-11", created_at: "2019-02-17 11:11:52", updated_at: "2019-02-17 11:11:52"},
        {id: 8362040, owner_id: 84057, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-15 10:18:03", updated_at: "2019-02-15 10:18:03"},
        {id: 8350392, owner_id: 7294606, owner_type: "AndroidApp", activity_type: 0, activities_count: 13, week: "2019-02-11", created_at: "2019-02-14 00:35:22", updated_at: "2019-02-14 00:35:22"},
        {id: 8360091, owner_id: 7332597, owner_type: "AndroidApp", activity_type: 0, activities_count: 22, week: "2019-02-11", created_at: "2019-02-14 10:58:15", updated_at: "2019-02-14 10:58:15"},
        {id: 8364959, owner_id: 1758456, owner_type: "AndroidApp", activity_type: 0, activities_count: 4, week: "2019-02-11", created_at: "2019-02-15 14:58:41", updated_at: "2019-02-15 14:58:41"},
        {id: 8373066, owner_id: 5146212, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-16 04:20:47", updated_at: "2019-02-16 04:20:47"},
        {id: 8373760, owner_id: 5373646, owner_type: "AndroidApp", activity_type: 0, activities_count: 2, week: "2019-02-11", created_at: "2019-02-16 05:56:55", updated_at: "2019-02-16 05:56:55"},
        {id: 8334941, owner_id: 14685, owner_type: "AndroidApp", activity_type: 0, activities_count: 4, week: "2019-02-11", created_at: "2019-02-12 09:48:19", updated_at: "2019-02-12 09:48:19"},
        {id: 8335007, owner_id: 23881, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-12 09:51:34", updated_at: "2019-02-12 09:51:34"},
        {id: 8346461, owner_id: 6472076, owner_type: "AndroidApp", activity_type: 0, activities_count: 4, week: "2019-02-11", created_at: "2019-02-13 09:07:50", updated_at: "2019-02-13 09:07:50"},
        {id: 8369426, owner_id: 3364410, owner_type: "AndroidApp", activity_type: 0, activities_count: 5, week: "2019-02-11", created_at: "2019-02-15 22:16:40", updated_at: "2019-02-15 22:16:40"},
        {id: 8347345, owner_id: 6779393, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-13 12:47:24", updated_at: "2019-02-13 12:47:24"},
        {id: 8368267, owner_id: 2929651, owner_type: "AndroidApp", activity_type: 0, activities_count: 6, week: "2019-02-11", created_at: "2019-02-15 19:56:26", updated_at: "2019-02-15 19:56:26"},
        {id: 8368152, owner_id: 2873265, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-15 19:38:49", updated_at: "2019-02-15 19:38:49"},
        {id: 8376952, owner_id: 6869188, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-16 17:07:16", updated_at: "2019-02-16 17:07:16"},
        {id: 8339317, owner_id: 2841424, owner_type: "AndroidApp", activity_type: 0, activities_count: 3, week: "2019-02-11", created_at: "2019-02-12 16:46:26", updated_at: "2019-02-12 16:46:26"},
        {id: 8377208, owner_id: 6946767, owner_type: "AndroidApp", activity_type: 0, activities_count: 13, week: "2019-02-11", created_at: "2019-02-16 18:24:52", updated_at: "2019-02-16 18:24:52"},
        {id: 8335135, owner_id: 55231, owner_type: "AndroidApp", activity_type: 0, activities_count: 4, week: "2019-02-11", created_at: "2019-02-12 10:02:10", updated_at: "2019-02-12 10:02:10"},
        {id: 8338330, owner_id: 2288960, owner_type: "AndroidApp", activity_type: 0, activities_count: 9, week: "2019-02-11", created_at: "2019-02-12 14:59:47", updated_at: "2019-02-12 14:59:47"},
        {id: 8366278, owner_id: 2215945, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-15 16:31:32", updated_at: "2019-02-15 16:31:32"},
        {id: 8361931, owner_id: 60838, owner_type: "AndroidApp", activity_type: 0, activities_count: 1, week: "2019-02-11", created_at: "2019-02-15 10:07:25", updated_at: "2019-02-15 10:07:25"},
        {id: 8334456, owner_id: 7111107, owner_type: "AndroidApp", activity_type: 0, activities_count: 29, week: "2019-02-11", created_at: "2019-02-11 11:49:32", updated_at: "2019-02-11 11:49:32"},
        {id: 8343925, owner_id: 5122504, owner_type: "AndroidApp", activity_type: 0, activities_count: 6, week: "2019-02-11", created_at: "2019-02-13 00:29:09", updated_at: "2019-02-13 00:29:09"}
    ]

    arr_week1 = week1.map do |weekly_batch|
      owner = {
          id: 4292150,
          created_at: '3 2019-03-08 10:57:37.000000000 Z',
          updated_at: '4 2019-03-08 10:57:37.000000000 Z',
          app_identifier: 1451505313,
          app_id: '',
          newest_ios_app_snapshot_id: '',
          user_base: '',
          mobile_priority: '',
          released: '',
          newest_ipa_snapshot_id: '',
          display_type: 0,
          ios_developer_id: 136666,
          source: 5,
          app_name: 'test',
          mightysignal_public_page_link: '#'
      }

      #  id          :integer          not null, primary key
      #  created_at  :datetime
      #  updated_at  :datetime
      #  happened_at :datetime
      #  major_app   :boolean          default(FALSE)
      sorted_activities = Array.new
      rand(30).times do
        datetime = DateTime.now
        sorted_activities.push Activity.new(
            id: rand(1000...999999), created_at: datetime, updated_at: datetime, happened_at: datetime, major_app: false
        )
      end

      weekly_batch[:sorted_activities] = sorted_activities
      weekly_batch[:owner] = OpenStruct.new(owner)
      OpenStruct.new(weekly_batch)
    end
    arr_week2 = week2.map do |weekly_batch|
      owner = {
          id: 4292150,
          created_at: '3 2019-03-08 10:57:37.000000000 Z',
          updated_at: '4 2019-03-08 10:57:37.000000000 Z',
          app_identifier: 1451505313,
          app_id: '',
          newest_ios_app_snapshot_id: '',
          user_base: '',
          mobile_priority: '',
          released: '',
          newest_ipa_snapshot_id: '',
          display_type: 0,
          ios_developer_id: 136666,
          source: 5,
          app_name: 'test',
          mightysignal_public_page_link: '#'
      }

      #  id          :integer          not null, primary key
      #  created_at  :datetime
      #  updated_at  :datetime
      #  happened_at :datetime
      #  major_app   :boolean          default(FALSE)
      sorted_activities = Array.new
      rand(30).times do
        datetime = DateTime.now
        sorted_activities.push Activity.new(
            id: rand(1000...999999), created_at: datetime, updated_at: datetime, happened_at: datetime, major_app: false
        )
      end

      weekly_batch[:sorted_activities] = sorted_activities
      weekly_batch[:owner] = OpenStruct.new(owner)
      OpenStruct.new(weekly_batch)
    end
    arr_week3 = week3.map do |weekly_batch|
      owner = {
          id: 4292150,
          created_at: '3 2019-03-08 10:57:37.000000000 Z',
          updated_at: '4 2019-03-08 10:57:37.000000000 Z',
          app_identifier: 1451505313,
          app_id: '',
          newest_ios_app_snapshot_id: '',
          user_base: '',
          mobile_priority: '',
          released: '',
          newest_ipa_snapshot_id: '',
          display_type: 0,
          ios_developer_id: 136666,
          source: 5,
          app_name: 'test',
          mightysignal_public_page_link: '#'
      }

      #  id          :integer          not null, primary key
      #  created_at  :datetime
      #  updated_at  :datetime
      #  happened_at :datetime
      #  major_app   :boolean          default(FALSE)
      sorted_activities = Array.new
      rand(30).times do
        datetime = DateTime.now
        sorted_activities.push Activity.new(
            id: rand(1000...999999), created_at: datetime, updated_at: datetime, happened_at: datetime, major_app: false
        )
      end

      weekly_batch[:sorted_activities] = sorted_activities
      weekly_batch[:owner] = OpenStruct.new(owner)
      OpenStruct.new(weekly_batch)
    end
    arr_week4 = week4.map do |weekly_batch|
      owner = {
          id: 4292150,
          created_at: '3 2019-03-08 10:57:37.000000000 Z',
          updated_at: '4 2019-03-08 10:57:37.000000000 Z',
          app_identifier: 1451505313,
          app_id: '',
          newest_ios_app_snapshot_id: '',
          user_base: '',
          mobile_priority: '',
          released: '',
          newest_ipa_snapshot_id: '',
          display_type: 0,
          ios_developer_id: 136666,
          source: 5,
          app_name: 'test',
          mightysignal_public_page_link: '#'
      }

      #  id          :integer          not null, primary key
      #  created_at  :datetime
      #  updated_at  :datetime
      #  happened_at :datetime
      #  major_app   :boolean          default(FALSE)
      sorted_activities = Array.new
      rand(30).times do
        datetime = DateTime.now
        sorted_activities.push Activity.new(
            id: rand(1000...999999), created_at: datetime, updated_at: datetime, happened_at: datetime, major_app: false
        )
      end

      weekly_batch[:sorted_activities] = sorted_activities
      weekly_batch[:owner] = OpenStruct.new(owner)
      OpenStruct.new(weekly_batch)
    end
    # arr_week2 = week2.map {|weekly_batch| OpenStruct.new(weekly_batch)}
    # arr_week3 = week3.map {|weekly_batch| OpenStruct.new(weekly_batch)}
    # arr_week4 = week4.map {|weekly_batch| OpenStruct.new(weekly_batch)}

    {
        Date.strptime('2019-03-04', "%Y-%m-%d") => arr_week1,
        Date.strptime('2019-02-25', "%Y-%m-%d") => arr_week2,
        Date.strptime('2019-02-18', "%Y-%m-%d") => arr_week3,
        Date.strptime('2019-02-11', "%Y-%m-%d") => arr_week4
    }
  end

  def mock_other_owner
    OpenStruct.new({
        id: 4292150,
        created_at: '3 2019-03-08 10:57:37.000000000 Z',
        updated_at: '4 2019-03-08 10:57:37.000000000 Z',
        app_identifier: 1451505313,
        app_id: '111',
        newest_ios_app_snapshot_id: '111',
        user_base: '111',
        mobile_priority: '111',
        released: '111',
        newest_ipa_snapshot_id: '11',
        display_type: 0,
        ios_developer_id: 136666,
        source: 5,
        favicon: '#'
    })
  end

  # =======================================================================================
  # app page data
  def mock_app_json_app
    json_app = {
        "newcomers" => [
            {"date" => "2018-04-11T07:17:09.617999+00:00", "country" => "143521", "category" => "6015", "rank" => 665, "ranking_type" => "27"},
            {"date" => "2018-04-18T08:17:45.235541+00:00", "country" => "BS", "category" => "36", "rank" => 659, "ranking_type" => "free"},
            {"date" => "2018-04-18T08:17:45.235541+00:00", "country" => "143539", "category" => "36", "rank" => 659, "ranking_type" => "27"},
            {"date" => "2018-04-11T07:17:09.617999+00:00", "country" => "MT", "category" => "6015", "rank" => 665, "ranking_type" => "free"},
            {"date" => "2018-04-24T02:01:22.486297+00:00", "country" => "TZ", "category" => "6015", "rank" => 624, "ranking_type" => "free"},
            {"date" => "2018-04-25T05:00:26.757510+00:00", "country" => "BZ", "category" => "6015", "rank" => 3, "ranking_type" => "free"},
            {"date" => "2018-04-25T04:57:45.355120+00:00", "country" => "BZ", "category" => "36", "rank" => 418, "ranking_type" => "free"},
            {"date" => "2018-05-14T06:27:48.319586+00:00", "country" => "LC", "category" => "6015", "rank" => 1232, "ranking_type" => "free"},
            {"date" => "2018-05-16T02:42:09.664266+00:00", "country" => "TC", "category" => "6015", "rank" => 4, "ranking_type" => "free"},
            {"date" => "2018-05-16T02:38:30.606277+00:00", "country" => "TC", "category" => "36", "rank" => 149, "ranking_type" => "free"},
            {"date" => "2018-05-30T04:10:01.380485+00:00", "country" => "KH", "category" => "6015", "rank" => 190, "ranking_type" => "free"},
            {"date" => "2018-07-16T01:19:34.148068+00:00", "country" => "KY", "category" => "36", "rank" => 246, "ranking_type" => "free"},
            {"date" => "2018-07-18T04:01:16.233604+00:00", "country" => "KW", "category" => "6015", "rank" => 279, "ranking_type" => "free"},
            {"date" => "2018-08-04T04:35:55.398354+00:00", "country" => "TM", "category" => "6015", "rank" => 298, "ranking_type" => "free"},
            {"date" => "2018-08-28T06:14:37.350459+00:00", "country" => "VC", "category" => "6015", "rank" => 5, "ranking_type" => "free"},
            {"date" => "2018-08-28T06:17:50.858974+00:00", "country" => "VC", "category" => "36", "rank" => 221, "ranking_type" => "free"},
            {"date" => "2019-01-17T02:38:13.306294+00:00", "country" => "LU", "category" => "6015", "rank" => 48, "ranking_type" => "free"},
            {"date" => "2019-01-20T05:08:05.852143+00:00", "country" => "BB", "category" => "6015", "rank" => 13, "ranking_type" => "free"},
            {"date" => "2019-01-20T05:10:39.494479+00:00", "country" => "BB", "category" => "36", "rank" => 737, "ranking_type" => "free"},
            {"date" => "2019-02-11T19:07:04.462345+00:00", "country" => "PW", "category" => "6015", "rank" => 514, "ranking_type" => "free"},
            {"date" => "2019-02-11T21:39:47.790558+00:00", "country" => "TZ", "category" => "36", "rank" => 1363, "ranking_type" => "free"},
            {"date" => "2019-02-20T03:19:05.143156+00:00", "country" => "GY", "category" => "6015", "rank" => 150, "ranking_type" => "free"}
        ],
        "all_version_ratings_count" => 1860,
        "current_version_rating" => "3.5",
        "sdk_activity" => [
            {"id" => 67, "name" => "AFNetworking", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["Networking"], "installed" => true},
            {"id" => 99, "name" => "Answers", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["Analytics"], "installed" => true},
            {"id" => 387, "name" => "BNRDynamicTypeManager", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 457, "name" => "BSKeyboardControls", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 650, "name" => "CXFeedParser", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 714, "name" => "Crashlytics", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["App Performance Management"], "installed" => true},
            {"id" => 911, "name" => "Fabric", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["Backend"], "installed" => true},
            {"id" => 1117, "name" => "GoogleAnalytics", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["Analytics"], "installed" => true},
            {"id" => 1158, "name" => "GoogleUtilities", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["Utilities"], "installed" => true},
            {"id" => 1822, "name" => "Mantle", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["Utilities"], "installed" => true},
            {"id" => 1840, "name" => "MBProgressHUD", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["UI"], "installed" => true},
            {"id" => 1850, "name" => "MBCircularProgressBar", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 2405, "name" => "PBWebViewController", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 2457, "name" => "pop", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["UI"], "installed" => true},
            {"id" => 2531, "name" => "PureLayout", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["UI"], "installed" => true},
            {"id" => 2557, "name" => "RaptureXML", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 2780, "name" => "SDWebImage", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["Media"], "installed" => true},
            {"id" => 3176, "name" => "TPKeyboardAvoiding", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["UI"], "installed" => true},
            {"id" => 3205, "name" => "UAObfuscatedString", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 3300, "name" => "TTTAttributedLabel", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => ["UI"], "installed" => true},
            {"id" => 3302, "name" => "TUSafariActivity", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 3308, "name" => "UALogger", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 3565, "name" => "XMLDictionary", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 3712, "name" => "Twitter", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}
             ],
             "categories" => nil, "installed" => true},
            {"id" => 1032, "name" => "FMDB", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2017-12-11T20:52:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2017-12-11T20:52:42.000-08:00"}
             ],
             "categories" => ["Backend"], "installed" => true},
            {"id" => 1162, "name" => "Google-AdMob-Ads-SDK", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2017-12-11T20:52:42.000-08:00",
             "activities" => [
                 {"type" => "install", "date" => "2017-12-11T20:52:42.000-08:00"}
             ],
             "categories" => ["Monetization", "Ad-Mediation"],
             "installed" => true}
        ],
        "countries_available_in" => ["US", "GB"],
        "current_version" => "5.4.3",
        "publisher" => {"app_store_id" => 414113285, "platform" => "ios", "id" => 45752, "name" => "Internal Revenue Service"},
        "taken_down" => false, "support_url" => "https://www.irs.gov/refunds", "description" => "Check your refund status, make a payment, find free tax preparation assistance, sign up for helpful tax tips, generate a login security code, and follow the latest news from the IRS - all in the latest version of IRS2Go.\n\nDownload IRS2Go and connect with the IRS whenever you want, wherever you are.\n\nIRS2Go is the official app of the Internal Revenue Service. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
        "current_version_ratings_count" => 164,
        "user_base_by_country" => [{"country_code" => "GB", "country" => "United Kingdom", "user_base" => "weak"},
                                   {"country_code" => "US", "country" => "United States", "user_base" => "strong"}],
        "first_scraped" => "2015-01-31",
        "app_identifier" => 414113282, "icon_url" => "https://is4-ssl.mzstatic.com/image/thumb/Purple128/v4/1b/66/7a/1b667af9-9bc2-00d3-38c7-4ed393767544/source/100x100bb.jpg", "first_scanned_date" => "2017-06-09T22:54:01Z", "original_release_date" => "2011-01-20",
        "versions_history" => [
            {"version" => "5.0", "released" => "2015-01-31"},
            {"version" => "5.1", "released" => "2015-05-11"},
            {"version" => "5.1.1", "released" => "2015-06-16"},
            {"version" => "5.2", "released" => "2015-08-16"},
            {"version" => "5.2.2", "released" => "2016-01-13"},
            {"version" => "5.3", "released" => "2016-12-11"},
            {"version" => "5.3.1", "released" => "2016-12-22"},
            {"version" => "5.3.1", "released" => "2017-11-04"},
            {"version" => "5.4", "released" => "2017-12-10"},
            {"version" => "5.4.1", "released" => "2017-12-20"},
            {"version" => "5.4.2", "released" => "2018-01-25"},
            {"version" => "5.4.3", "released" => "2018-11-18"}
        ],
        "id" => 103766,
        "headquarters" => [
            {"domain" => "irs.gov", "street_number" => nil, "street_name" => "Constitution NW Ave", "sub_premise" => "1111", "city" => "Washington", "postal_code" => "20224", "state" => "Washington D.C.", "state_code" => "DC", "country" => "United States", "country_code" => "US", "lat" => "38.89214", "lng" => "-77.02638"}
        ],
        "bundle_identifier" => "gov.irs.IRS2Go", "mobile_priority" => "medium",
        "ratings_by_country" => [
            {"current_rating" => 1.0, "ratings_current_count" => 1, "ratings_per_day_current_release" => 0.0, "country_code" => "GB", "rating" => 0.0, "ratings_count" => 0, "country" => "United Kingdom"},
            {"current_rating" => 3.5, "ratings_current_count" => 164, "ratings_per_day_current_release" => 1.0, "country_code" => "US", "rating" => 3.0, "ratings_count" => 1860, "country" => "United States"}
        ],
        "major_app" => true, "all_version_rating" => 3.0,
        "ratings_history" => [
            {"start_date" => "2015-03-30T16:54:57.000-07:00", "stop_date" => "2015-03-31T01:14:30.000-07:00", "ratings_all_count" => 1217, "ratings_all_stars" => "3.0"},
            {"start_date" => "2015-04-15T23:49:43.000-07:00", "stop_date" => "2015-04-15T23:49:43.000-07:00", "ratings_all_count" => 1220, "ratings_all_stars" => "3.0"},
            {"start_date" => "2015-06-02T04:43:01.000-07:00", "stop_date" => "2015-06-02T04:43:01.000-07:00", "ratings_all_count" => 1225, "ratings_all_stars" => "3.0"},
            {"start_date" => "2015-06-19T13:42:52.000-07:00", "stop_date" => "2015-06-19T13:42:52.000-07:00", "ratings_all_count" => 0, "ratings_all_stars" => "3.0"},
            {"start_date" => "2015-10-14T17:47:00.000-07:00", "stop_date" => "2015-10-14T17:47:00.000-07:00", "ratings_all_count" => 1227, "ratings_all_stars" => "3.0"},
            {"start_date" => "2015-08-18T12:29:58.000-07:00", "stop_date" => "2015-12-18T13:39:12.000-08:00", "ratings_all_count" => 1226, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-01-19T12:46:40.000-08:00", "stop_date" => "2016-01-19T12:46:40.000-08:00", "ratings_all_count" => 1232, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-01-25T13:15:18.000-08:00", "stop_date" => "2016-01-25T13:15:18.000-08:00", "ratings_all_count" => 1238, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-02-01T17:53:09.000-08:00", "stop_date" => "2016-02-01T17:53:09.000-08:00", "ratings_all_count" => 1249, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-02-16T22:27:56.000-08:00", "stop_date" => "2016-02-16T22:27:56.000-08:00", "ratings_all_count" => 1264, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-03-04T00:04:30.000-08:00", "stop_date" => "2016-03-04T00:04:30.000-08:00", "ratings_all_count" => 1266, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-03-10T22:51:01.000-08:00", "stop_date" => "2016-03-10T22:51:01.000-08:00", "ratings_all_count" => 1269, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-03-21T00:28:25.000-07:00", "stop_date" => "2016-03-21T00:28:25.000-07:00", "ratings_all_count" => 1270, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-03-25T21:42:41.000-07:00", "stop_date" => "2016-03-25T21:42:41.000-07:00", "ratings_all_count" => 1272, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-04-01T15:57:43.000-07:00", "stop_date" => "2016-04-01T15:57:43.000-07:00", "ratings_all_count" => 1273, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-04-08T22:33:30.000-07:00", "stop_date" => "2016-04-08T22:33:30.000-07:00", "ratings_all_count" => 1275, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-04-16T09:48:50.000-07:00", "stop_date" => "2016-04-16T09:48:50.000-07:00", "ratings_all_count" => 1276, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-04-23T13:20:58.000-07:00", "stop_date" => "2016-04-23T13:20:58.000-07:00", "ratings_all_count" => 1277, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-05-07T00:04:44.000-07:00", "stop_date" => "2016-05-07T00:04:44.000-07:00", "ratings_all_count" => 1278, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-05-29T18:42:50.000-07:00", "stop_date" => "2016-07-17T15:46:19.000-07:00", "ratings_all_count" => 1279, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-05-13T23:16:52.000-07:00", "stop_date" => "2016-09-02T22:57:33.000-07:00", "ratings_all_count" => 1280, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-09-05T17:34:49.000-07:00", "stop_date" => "2016-09-11T19:18:40.000-07:00", "ratings_all_count" => 1281, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-09-17T10:32:34.000-07:00", "stop_date" => "2016-11-26T04:29:55.000-08:00", "ratings_all_count" => 1282, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-12-03T04:31:23.000-08:00", "stop_date" => "2016-12-17T15:30:41.000-08:00", "ratings_all_count" => 1283, "ratings_all_stars" => "3.0"},
            {"start_date" => "2016-12-25T07:13:23.000-08:00", "stop_date" => "2017-01-01T08:02:40.000-08:00", "ratings_all_count" => 1284, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-01-10T10:55:59.000-08:00", "stop_date" => "2017-01-14T19:05:04.000-08:00", "ratings_all_count" => 1285, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-01-21T09:52:09.000-08:00", "stop_date" => "2017-01-21T09:52:09.000-08:00", "ratings_all_count" => 1286, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-01-28T09:55:12.000-08:00", "stop_date" => "2017-01-28T09:55:12.000-08:00", "ratings_all_count" => 1290, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-02-11T11:21:20.000-08:00", "stop_date" => "2017-02-11T11:21:20.000-08:00", "ratings_all_count" => 1304, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-02-20T20:18:45.000-08:00", "stop_date" => "2017-02-20T20:18:45.000-08:00", "ratings_all_count" => 1309, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-02-25T09:29:09.000-08:00", "stop_date" => "2017-02-25T09:29:09.000-08:00", "ratings_all_count" => 1311, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-03-12T20:19:18.000-07:00", "stop_date" => "2017-03-18T11:43:57.000-07:00", "ratings_all_count" => 1318, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-03-25T10:40:57.000-07:00", "stop_date" => "2017-03-25T10:40:57.000-07:00", "ratings_all_count" => 1322, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-04-08T21:13:34.000-07:00", "stop_date" => "2017-04-08T21:13:34.000-07:00", "ratings_all_count" => 1327, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-06-24T15:49:15.000-07:00", "stop_date" => "2017-08-19T05:53:52.000-07:00", "ratings_all_count" => 1330, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-04-15T11:17:56.000-07:00", "stop_date" => "2017-10-13T05:50:10.000-07:00", "ratings_all_count" => 1328, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-05-06T10:39:57.000-07:00", "stop_date" => "2017-10-20T06:04:50.000-07:00", "ratings_all_count" => 1329, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-10-28T05:53:38.000-07:00", "stop_date" => "2017-11-18T16:48:58.000-08:00", "ratings_all_count" => 1331, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-11-24T20:52:37.000-08:00", "stop_date" => "2017-12-01T19:46:44.000-08:00", "ratings_all_count" => 1333, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-12-11T10:53:05.000-08:00", "stop_date" => "2017-12-11T19:59:13.000-08:00", "ratings_all_count" => 1334, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-12-16T21:00:53.000-08:00", "stop_date" => "2017-12-17T05:26:34.000-08:00", "ratings_all_count" => 1338, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-12-24T00:56:16.000-08:00", "stop_date" => "2017-12-24T00:56:16.000-08:00", "ratings_all_count" => 1339, "ratings_all_stars" => "3.0"},
            {"start_date" => "2017-12-30T12:52:03.000-08:00", "stop_date" => "2017-12-30T17:35:46.000-08:00", "ratings_all_count" => 1345, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-01-06T16:50:45.000-08:00", "stop_date" => "2018-01-07T05:37:35.000-08:00", "ratings_all_count" => 1348, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-01-29T19:10:28.000-08:00", "stop_date" => "2018-01-29T19:10:28.000-08:00", "ratings_all_count" => 1381, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-01-30T06:28:20.000-08:00", "stop_date" => "2018-01-30T10:33:40.000-08:00", "ratings_all_count" => 1387, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-01-30T11:47:52.000-08:00", "stop_date" => "2018-01-30T11:47:52.000-08:00", "ratings_all_count" => 1390, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-03-02T17:08:53.000-08:00", "stop_date" => "2018-03-02T18:37:45.000-08:00", "ratings_all_count" => 1577, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-03-10T01:49:16.000-08:00", "stop_date" => "2018-03-10T01:49:16.000-08:00", "ratings_all_count" => 1592, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-03-17T14:10:42.000-07:00", "stop_date" => "2018-03-17T14:10:42.000-07:00", "ratings_all_count" => 1597, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-03-24T06:15:57.000-07:00", "stop_date" => "2018-03-24T06:15:57.000-07:00", "ratings_all_count" => 1604, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-03-31T05:58:10.000-07:00", "stop_date" => "2018-03-31T05:58:10.000-07:00", "ratings_all_count" => 1607, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-04-07T13:58:15.000-07:00", "stop_date" => "2018-04-07T13:58:15.000-07:00", "ratings_all_count" => 1620, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-04-14T06:07:21.000-07:00", "stop_date" => "2018-04-14T06:07:21.000-07:00", "ratings_all_count" => 1640, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-04-21T05:55:14.000-07:00", "stop_date" => "2018-04-21T05:55:14.000-07:00", "ratings_all_count" => 1652, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-04-29T09:56:16.000-07:00", "stop_date" => "2018-04-29T09:56:16.000-07:00", "ratings_all_count" => 1662, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-05-05T06:07:45.000-07:00", "stop_date" => "2018-05-05T06:07:45.000-07:00", "ratings_all_count" => 1669, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-05-12T05:55:39.000-07:00", "stop_date" => "2018-05-12T05:55:39.000-07:00", "ratings_all_count" => 1675, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-05-19T18:02:00.000-07:00", "stop_date" => "2018-05-19T18:02:00.000-07:00", "ratings_all_count" => 1679, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-06-03T01:58:11.000-07:00", "stop_date" => "2018-06-03T01:58:11.000-07:00", "ratings_all_count" => 1681, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-06-09T09:58:02.000-07:00", "stop_date" => "2018-06-09T17:57:18.000-07:00", "ratings_all_count" => 1682, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-06-16T13:59:56.000-07:00", "stop_date" => "2018-06-16T18:12:41.000-07:00", "ratings_all_count" => 1684, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-06-23T22:00:44.000-07:00", "stop_date" => "2018-06-23T22:00:44.000-07:00", "ratings_all_count" => 1688, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-06-30T13:59:04.000-07:00", "stop_date" => "2018-06-30T13:59:04.000-07:00", "ratings_all_count" => 1692, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-07-09T16:29:34.000-07:00", "stop_date" => "2018-07-09T16:29:34.000-07:00", "ratings_all_count" => 1695, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-07-16T01:59:18.000-07:00", "stop_date" => "2018-07-16T03:40:43.000-07:00", "ratings_all_count" => 1697, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-07-22T01:58:13.000-07:00", "stop_date" => "2018-07-22T05:10:09.000-07:00", "ratings_all_count" => 1698, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-07-29T16:59:04.000-07:00", "stop_date" => "2018-08-05T22:01:44.000-07:00", "ratings_all_count" => 1700, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-08-12T05:58:53.000-07:00", "stop_date" => "2018-08-19T09:59:13.000-07:00", "ratings_all_count" => 1702, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-08-26T18:00:53.000-07:00", "stop_date" => "2018-08-27T02:13:10.000-07:00", "ratings_all_count" => 1705, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-09-02T05:59:19.000-07:00", "stop_date" => "2018-09-02T11:15:48.000-07:00", "ratings_all_count" => 1707, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-09-10T21:58:42.000-07:00", "stop_date" => "2018-09-11T02:14:42.000-07:00", "ratings_all_count" => 1708, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-09-16T09:58:02.000-07:00", "stop_date" => "2018-09-16T11:55:35.000-07:00", "ratings_all_count" => 1709, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-09-23T14:00:17.000-07:00", "stop_date" => "2018-09-23T15:48:42.000-07:00", "ratings_all_count" => 1712, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-09-30T13:58:19.000-07:00", "stop_date" => "2018-09-30T19:50:52.000-07:00", "ratings_all_count" => 1711, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-10-14T18:07:11.000-07:00", "stop_date" => "2018-10-14T18:07:11.000-07:00", "ratings_all_count" => 1713, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-10-21T18:00:04.000-07:00", "stop_date" => "2018-10-21T18:00:04.000-07:00", "ratings_all_count" => 1714, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-10-28T21:57:25.000-07:00", "stop_date" => "2018-10-28T21:57:25.000-07:00", "ratings_all_count" => 1716, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-10-30T22:46:50.000-07:00", "stop_date" => "2018-11-04T09:01:19.000-08:00", "ratings_all_count" => 1715, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-11-15T17:01:06.000-08:00", "stop_date" => "2018-11-15T17:01:06.000-08:00", "ratings_all_count" => 1718, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-11-21T09:01:42.000-08:00", "stop_date" => "2018-12-03T09:00:13.000-08:00", "ratings_all_count" => 1723, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-12-10T20:58:17.000-08:00", "stop_date" => "2018-12-10T20:58:17.000-08:00", "ratings_all_count" => 1725, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-12-18T11:34:51.000-08:00", "stop_date" => "2018-12-25T20:58:56.000-08:00", "ratings_all_count" => 1729, "ratings_all_stars" => "3.0"},
            {"start_date" => "2018-12-18T04:58:27.000-08:00", "stop_date" => "2018-12-31T13:00:49.000-08:00", "ratings_all_count" => 1728, "ratings_all_stars" => "3.0"},
            {"start_date" => "2019-01-16T04:59:24.000-08:00", "stop_date" => "2019-01-26T16:59:25.000-08:00", "ratings_all_count" => 1730, "ratings_all_stars" => "3.0"},
            {"start_date" => "2019-02-03T09:18:20.000-08:00", "stop_date" => "2019-02-03T09:18:20.000-08:00", "ratings_all_count" => 1768, "ratings_all_stars" => "3.0"},
            {"start_date" => "2019-02-09T16:58:14.000-08:00", "stop_date" => nil, "ratings_all_count" => 1807, "ratings_all_stars" => "3.0"}
        ],
        "rankings" => {"date" => "2019-02-22T09:58:49.626824", "charts" => [{"category" => "6015", "monthly_change" => 52, "country" => "LR", "rank" => 318, "ranking_type" => "free", "weekly_change" => -230}, {"category" => "6015", "monthly_change" => nil, "country" => "PW", "rank" => 20, "ranking_type" => "free", "weekly_change" => 493}, {"category" => "6015", "monthly_change" => 80, "country" => "BM", "rank" => 514, "ranking_type" => "free", "weekly_change" => -5},
                                                                            {"category" => "6015", "monthly_change" => 517, "country" => "UZ", "rank" => 701, "ranking_type" => "free",
                                                                             "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 140, "country" => "PY", "rank" => 426, "ranking_type" => "free", "weekly_change" => 131}, {"category" => "6015", "monthly_change" => 17, "country" => "FM", "rank" => 84, "ranking_type" => "free", "weekly_change" => 22},
                                                                            {"category" => "6015", "monthly_change" => -307, "country" => "AE", "rank" => 784, "ranking_type" => "free",
                                                                             "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 129, "country" => "UG", "rank" => 1305, "ranking_type" => "free", "weekly_change" => -67}, {"category" => "6015", "monthly_change" => 210, "country" => "KZ", "rank" => 1210, "ranking_type" => "free", "weekly_change" => -977},
                                                                            {"category" => "6015", "monthly_change" => 417, "country" => "EC", "rank" => 217, "ranking_type" => "free",
                                                                             "weekly_change" => -126}, {"category" => "6015", "monthly_change" => nil, "country" => "KE", "rank" => 1465, "ranking_type" => "free", "weekly_change" => -469}, {"category" => "6015", "monthly_change" => 332, "country" => "MX", "rank" => 95, "ranking_type" => "free", "weekly_change" => 45},
                                                                            {"category" => "6015", "monthly_change" => nil, "country" => "ID", "rank" => 529, "ranking_type" => "free",
                                                                             "weekly_change" => nil}, {"category" => "6015", "monthly_change" => -61, "country" => "CO", "rank" => 1031, "ranking_type" => "free", "weekly_change" => -36}, {"category" => "6015", "monthly_change" => -10, "country" => "SL", "rank" => 533, "ranking_type" => "free", "weekly_change" => -44},
                                                                            {"category" => "6015", "monthly_change" => -221, "country" => "LB", "rank" => 1396, "ranking_type" => "free",
                                                                             "weekly_change" => -149}, {"category" => "6015", "monthly_change" => 129, "country" => "MD", "rank" => 1169, "ranking_type" => "free", "weekly_change" => -347}, {"category" => "6015", "monthly_change" => 68, "country" => "VC", "rank" => 934, "ranking_type" => "free", "weekly_change" => 65},
                                                                            {"category" => "6015", "monthly_change" => nil, "country" => "TZ", "rank" => 918, "ranking_type" => "free",
                                                                             "weekly_change" => -797}, {"category" => "36", "monthly_change" => 221, "country" => "US", "rank" => 2, "ranking_type" => "free", "weekly_change" => 7}, {"category" => "6015", "monthly_change" => -21, "country" => "GW", "rank" => 461, "ranking_type" => "free", "weekly_change" => 64}, {"category" => "6015", "monthly_change" => 9, "country" => "AR", "rank" => 1066, "ranking_type" => "free", "weekly_change" => 54},
                                                                            {"category" => "6015", "monthly_change" => 61, "country" => "KN", "rank" => 928, "ranking_type" => "free",
                                                                             "weekly_change" => -167}, {"category" => "6015", "monthly_change" => 440, "country" => "IN", "rank" => 877, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015", "monthly_change" => nil, "country" => "PL", "rank" => 231, "ranking_type" => "free", "weekly_change" => nil},
                                                                            {"category" => "6015", "monthly_change" => 368, "country" => "AI", "rank" => 156, "ranking_type" => "free",
                                                                             "weekly_change" => -151}, {"category" => "6015", "monthly_change" => 32, "country" => "JM", "rank" => 14, "ranking_type" => "free", "weekly_change" => 2}, {"category" => "6015", "monthly_change" => 9, "country" => "SV", "rank" => 393, "ranking_type" => "free", "weekly_change" => -44}, {"category" => "6015", "monthly_change" => 43, "country" => "MW", "rank" => 1014, "ranking_type" => "free", "weekly_change" => -36},
                                                                            {"category" => "6015", "monthly_change" => -2, "country" => "LT", "rank" => 568, "ranking_type" => "free",
                                                                             "weekly_change" => -89}, {"category" => "6015", "monthly_change" => nil, "country" => "CH", "rank" => 636, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 44, "country" => "AG", "rank" => 332, "ranking_type" => "free", "weekly_change" => -152},
                                                                            {"category" => "6015", "monthly_change" => 104, "country" => "GD", "rank" => 849, "ranking_type" => "free",
                                                                             "weekly_change" => -49}, {"category" => "6015", "monthly_change" => nil, "country" => "GY", "rank" => 174, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 261, "country" => "KY", "rank" => 574, "ranking_type" => "free", "weekly_change" => -375},
                                                                            {"category" => "36", "monthly_change" => nil, "country" => "JM", "rank" => 504, "ranking_type" => "free",
                                                                             "weekly_change" => 142}, {"category" => "6015", "monthly_change" => nil, "country" => "HK", "rank" => 978, "ranking_type" => "free", "weekly_change" => 343}, {"category" => "6015", "monthly_change" => 516, "country" => "PH", "rank" => 115, "ranking_type" => "free", "weekly_change" => 23},
                                                                            {"category" => "6015", "monthly_change" => -26, "country" => "PA", "rank" => 1153, "ranking_type" => "free",
                                                                             "weekly_change" => -29}, {"category" => "6015", "monthly_change" => 44, "country" => "VE", "rank" => 973, "ranking_type" => "free", "weekly_change" => 39}, {"category" => "6015", "monthly_change" => 770, "country" => "IE", "rank" => 508, "ranking_type" => "free", "weekly_change" => 611},
                                                                            {"category" => "6015", "monthly_change" => 21, "country" => "VG", "rank" => 284, "ranking_type" => "free",
                                                                             "weekly_change" => 20}, {"category" => "6015", "monthly_change" => 102, "country" => "HR", "rank" => 858, "ranking_type" => "free", "weekly_change" => 101}, {"category" => "6015", "monthly_change" => 802, "country" => "JO", "rank" => 222, "ranking_type" => "free", "weekly_change" => 631},
                                                                            {"category" => "6015", "monthly_change" => 200, "country" => "AL", "rank" => 746, "ranking_type" => "free",
                                                                             "weekly_change" => -121}, {"category" => "6015", "monthly_change" => 501, "country" => "CA", "rank" => 516, "ranking_type" => "free", "weekly_change" => 173}, {"category" => "6015", "monthly_change" => 7, "country" => "EG", "rank" => 1483, "ranking_type" => "free", "weekly_change" => -9},
                                                                            {"category" => "6015", "monthly_change" => -20, "country" => "MN", "rank" => 1282, "ranking_type" => "free",
                                                                             "weekly_change" => -7}, {"category" => "6015", "monthly_change" => 33, "country" => "NG", "rank" => 822, "ranking_type" => "free", "weekly_change" => -405}, {"category" => "6015", "monthly_change" => nil, "country" => "PK", "rank" => 345, "ranking_type" => "free", "weekly_change" => 1364},
                                                                            {"category" => "6015", "monthly_change" => -680, "country" => "GM", "rank" => 1454, "ranking_type" => "free",
                                                                             "weekly_change" => -6}, {"category" => "6015", "monthly_change" => nil, "country" => "QA", "rank" => 445, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015", "monthly_change" => nil, "country" => "TR", "rank" => 491, "ranking_type" => "free", "weekly_change" => nil},
                                                                            {"category" => "6015", "monthly_change" => 381, "country" => "RO", "rank" => 423, "ranking_type" => "free",
                                                                             "weekly_change" => 8}, {"category" => "6015", "monthly_change" => 396, "country" => "NI", "rank" => 51, "ranking_type" => "free", "weekly_change" => 377}, {"category" => "6015", "monthly_change" => 444, "country" => "FJ", "rank" => 973, "ranking_type" => "free", "weekly_change" => 67},
                                                                            {"category" => "6015", "monthly_change" => 345, "country" => "AM", "rank" => 856, "ranking_type" => "free",
                                                                             "weekly_change" => -109}, {"category" => "6015", "monthly_change" => -71, "country" => "TM", "rank" => 1456, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 48, "country" => "YE", "rank" => 254, "ranking_type" => "free", "weekly_change" => 52},
                                                                            {"category" => "6015", "monthly_change" => 6, "country" => "CL", "rank" => 1260, "ranking_type" => "free",
                                                                             "weekly_change" => -12}, {"category" => "6015", "monthly_change" => 2, "country" => "MR", "rank" => 1396, "ranking_type" => "free", "weekly_change" => -382}, {"category" => "6015", "monthly_change" => 9, "country" => "US", "rank" => 1, "ranking_type" => "free", "weekly_change" => 0},
                                                                            {"category" => "6015", "monthly_change" => -46, "country" => "MK", "rank" => 583, "ranking_type" => "free",
                                                                             "weekly_change" => 6}, {"category" => "6015", "monthly_change" => nil, "country" => "NZ", "rank" => 1341, "ranking_type" => "free", "weekly_change" => -139}, {"category" => "6015", "monthly_change" => 117, "country" => "DE", "rank" => 619, "ranking_type" => "free", "weekly_change" => nil},
                                                                            {"category" => "6015", "monthly_change" => 31, "country" => "DM", "rank" => 53, "ranking_type" => "free",
                                                                             "weekly_change" => -15}, {"category" => "6015", "monthly_change" => nil, "country" => "CZ", "rank" => 304, "ranking_type" => "free", "weekly_change" => 1159}, {"category" => "6015", "monthly_change" => nil, "country" => "BH", "rank" => 1465, "ranking_type" => "free", "weekly_change" => -9},
                                                                            {"category" => "6015", "monthly_change" => 39, "country" => "CR", "rank" => 662, "ranking_type" => "free",
                                                                             "weekly_change" => 100}, {"category" => "6015", "monthly_change" => nil, "country" => "RU", "rank" => 1169, "ranking_type" => "free", "weekly_change" => 112}, {"category" => "6015", "monthly_change" => nil, "country" => "UY", "rank" => 879, "ranking_type" => "free", "weekly_change" => nil},
                                                                            {"category" => "6015", "monthly_change" => 301, "country" => "DO", "rank" => 36, "ranking_type" => "free",
                                                                             "weekly_change" => 19}, {"category" => "6015", "monthly_change" => -231, "country" => "LC", "rank" => 1109, "ranking_type" => "free", "weekly_change" => -229}, {"category" => "6015", "monthly_change" => 42, "country" => "ML", "rank" => 946, "ranking_type" => "free", "weekly_change" => -69},
                                                                            {"category" => "6015", "monthly_change" => -5, "country" => "CV", "rank" => 358, "ranking_type" => "free",
                                                                             "weekly_change" => -45}, {"category" => "6015", "monthly_change" => -25, "country" => "PT", "rank" => 392, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 48, "country" => "BG", "rank" => 788, "ranking_type" => "free", "weekly_change" => -91},
                                                                            {"category" => "6015", "monthly_change" => 264, "country" => "DZ", "rank" => 586, "ranking_type" => "free",
                                                                             "weekly_change" => -4}, {"category" => "6015", "monthly_change" => nil, "country" => "FI", "rank" => 1322, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 1158, "country" => "BZ", "rank" => 159, "ranking_type" => "free", "weekly_change" => 974},
                                                                            {"category" => "6015", "monthly_change" => 201, "country" => "GH", "rank" => 1104, "ranking_type" => "free",
                                                                             "weekly_change" => 193}, {"category" => "6015", "monthly_change" => -13, "country" => "GT", "rank" => 466, "ranking_type" => "free", "weekly_change" => 0}, {"category" => "6015", "monthly_change" => 5, "country" => "HN", "rank" => 336, "ranking_type" => "free", "weekly_change" => 14}, {"category" => "6015", "monthly_change" => -94, "country" => "SK", "rank" => 214, "ranking_type" => "free", "weekly_change" => 926},
                                                                            {"category" => "6015", "monthly_change" => -1257, "country" => "BB", "rank" => 1371, "ranking_type" => "free",
                                                                             "weekly_change" => -266}, {"category" => "6015", "monthly_change" => 0, "country" => "TT", "rank" => 710, "ranking_type" => "free", "weekly_change" => 32}, {"category" => "6015", "monthly_change" => -442, "country" => "TC", "rank" => 1310, "ranking_type" => "free", "weekly_change" => -201},
                                                                            {"category" => "6015", "monthly_change" => 94, "country" => "BR", "rank" => 1258, "ranking_type" => "free",
                                                                             "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 223, "country" => "BS", "rank" => 302, "ranking_type" => "free", "weekly_change" => -124}, {"category" => "6015", "monthly_change" => 308, "country" => "PE", "rank" => 185, "ranking_type" => "free", "weekly_change" => -24},
                                                                            {"category" => "6015", "monthly_change" => -501, "country" => "IL", "rank" => 890, "ranking_type" => "free",
                                                                             "weekly_change" => 1}, {"category" => "6015", "monthly_change" => 76, "country" => "BO", "rank" => 946, "ranking_type" => "free", "weekly_change" => -423}, {"category" => "6015", "monthly_change" => 195, "country" => "MG", "rank" => 1104, "ranking_type" => "free", "weekly_change" => nil},
                                                                            {"category" => "6015", "monthly_change" => nil, "country" => "IT", "rank" => 671, "ranking_type" => "free",
                                                                             "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 1, "country" => "SN", "rank" => 933, "ranking_type" => "free", "weekly_change" => 62}, {"category" => "6015", "monthly_change" => nil, "country" => "ES", "rank" => 1140, "ranking_type" => "free", "weekly_change" => -1},
                                                                            {"category" => "6015", "monthly_change" => -340, "country" => "MZ", "rank" => 1453, "ranking_type" => "free",
                                                                             "weekly_change" => -244}, {"category" => "6015", "monthly_change" => 356, "country" => "AO", "rank" => 222, "ranking_type" => "free", "weekly_change" => 329}]}, "current_version_release_date" => "2018-11-18",
        "platform" => "ios", "categories" => [{"type" => "primary", "name" => "Finance", "id" => 6015}],
        "last_scanned_date" => "2019-02-21T00:40:55Z", "permissions" => ["Fabric", "CFBundleIcons",
                                                                         "CFBundleInfoDictionaryVersion", "DTXcodeBuild", "CFBundleSupportedPlatforms", "CFBundleIdentifier",
                                                                         "DTSDKName", "DTPlatformVersion", "CFBundleIcons~ipad", "CFBundleShortVersionString",
                                                                         "UILaunchImages", "NSLocationWhenInUseUsageDescription", "CFBundleDisplayName",
                                                                         "BuildMachineOSBuild", "DTAppStoreToolsBuild", "UILaunchStoryboardName", "MinimumOSVersion",
                                                                         "UIViewControllerBasedStatusBarAppearance", "CFBundleVersion", "CFBundleExecutable",
                                                                         "UIMainStoryboardFile", "UIDeviceFamily", "DTPlatformBuild", "UIRequiredDeviceCapabilities",
                                                                         "UIStatusBarStyle", "DTXcode", "CFBundleDevelopmentRegion", "DTPlatformName", "NSAppTransportSecurity",
                                                                         "UISupportedInterfaceOrientations~ipad", "UISupportedInterfaceOrientations", "DTCompiler",
                                                                         "CFBundleSignature", "LSRequiresIPhoneOS", "DTSDKBuild", "LSApplicationQueriesSchemes",
                                                                         "CFBundleName", "CFBundlePackageType"], "name" => "IRS2Go", "price" => 0, "seller_url" => "https://www.irs.gov/irs2go",
        "in_app_purchases" => false, "user_base" => "strong", "seller" => "Internal Revenue Service"}
    # json_app.to_json
  end

  def mock_app
    app = {id: 103766, created_at: "2015-03-14 07:46:50", updated_at: "2019-02-10 09:39:31",
           app_identifier: 414113282, app_id: 103766, newest_ios_app_snapshot_id: 273136238,
           user_base: 1, mobile_priority: 1, released: "2011-01-20", newest_ipa_snapshot_id: 1598526,
           display_type: 0, ios_developer_id: 45752, source: nil, fb_app_id: nil}
    OpenStruct.new(app)
  end

  def mock_app_json_publisher
    json_publisher = {"cached_domains" => [
        {"domain" => "irs.gov"}, {"domain" => "onpointcu.com"}],
                      "back_link_domains" => ["onpointcu.com", "wordpress.com"],
                      "details" => [{"name" => "Internal Revenue Service", "legal_name" => nil, "domain" => "irs.gov", "description" => "The Internal Revenue Service is the nation''s tax collection agency and administers the Internal Revenue Code enacted by Congress.", "company_type" => "government",
                                     "tags" => ["Consulting & Professional Services", "B2B"], "sector" => "Industrials", "industry_group" => "Commercial & Professional Services", "industry" => "Professional Services", "sub_industry" => "Consulting",
                                     "tech_used" => ["add_to_any", "new_relic", "twitter_button", "drupal", "youtube", "google_tag_manager", "google_analytics"], "founded_year" => nil, "time_zone" => "America/New_York", "utc_offset" => -4, "street_number" => "1111", "street_name" => "Constitution Avenue Northwest", "sub_premise" => nil, "city" => "Washington", "postal_code" => "20224", "state" => "District of Columbia", "state_code" => "DC", "country" => "United States", "country_code" => "US", "lat" => "38.893073", "lng" => "-77.027893", "logo_url" => nil,
                                     "facebook_handle" => "irs", "linkedin_handle" => "company/internal-revenue-service",
                                     "twitter_handle" => nil, "twitter_id" => nil, "crunchbase_handle" => "organization/internal-revenue-service-irs",
                                     "email_provider" => nil, "ticker" => nil, "phone" => nil, "alexa_us_rank" => 327, "alexa_global_rank" => 1551,
                                     "google_rank" => nil, "employees" => 79890, "employees_range" => "1000+", "market_cap" => nil,
                                     "raised" => nil, "annual_revenue" => nil, "fortune_1000_rank" => nil}],
                      "apps" => [{"id" => 103766, "platform" => "ios"}],
                      "app_store_id" => 414113285, "id" => 45752, "publisher_identifier" => 414113285, "platform" => "ios",
                      "websites" => ["http://www.irs.gov/irs2go", "https://www.irs.gov/irs2go", "https://www.irs.gov/refunds"], "name" => "Internal Revenue Service",
                      "domains" => ["gmccpa.com", "irs.gov", "prontotaxca.com"]}
    json_publisher.to_json
  end

  def mock_app_top_apps
    [{"newcomers" => [{"date" => "2018-04-11T07:17:09.617999+00:00", "country" => "143521",
                       "category" => "6015", "rank" => 665, "ranking_type" => "27"}, {"date" => "2018-04-18T08:17:45.235541+00:00",
                                                                                      "country" => "BS", "category" => "36", "rank" => 659, "ranking_type" => "free"}, {"date" => "2018-04-18T08:17:45.235541+00:00",
                                                                                                                                                                        "country" => "143539", "category" => "36", "rank" => 659, "ranking_type" => "27"}, {"date" => "2018-04-11T07:17:09.617999+00:00",
                                                                                                                                                                                                                                                            "country" => "MT", "category" => "6015", "rank" => 665, "ranking_type" => "free"}, {"date" => "2018-04-24T02:01:22.486297+00:00",
                                                                                                                                                                                                                                                                                                                                                "country" => "TZ", "category" => "6015", "rank" => 624, "ranking_type" => "free"}, {"date" => "2018-04-25T05:00:26.757510+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                    "country" => "BZ", "category" => "6015", "rank" => 3, "ranking_type" => "free"}, {"date" => "2018-04-25T04:57:45.355120+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      "country" => "BZ", "category" => "36", "rank" => 418, "ranking_type" => "free"}, {"date" => "2018-05-14T06:27:48.319586+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        "country" => "LC", "category" => "6015", "rank" => 1232, "ranking_type" => "free"}, {"date" => "2018-05-16T02:42:09.664266+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             "country" => "TC", "category" => "6015", "rank" => 4, "ranking_type" => "free"}, {"date" => "2018-05-16T02:38:30.606277+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               "country" => "TC", "category" => "36", "rank" => 149, "ranking_type" => "free"}, {"date" => "2018-05-30T04:10:01.380485+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 "country" => "KH", "category" => "6015", "rank" => 190, "ranking_type" => "free"}, {"date" => "2018-07-16T01:19:34.148068+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     "country" => "KY", "category" => "36", "rank" => 246, "ranking_type" => "free"}, {"date" => "2018-07-18T04:01:16.233604+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       "country" => "KW", "category" => "6015", "rank" => 279, "ranking_type" => "free"}, {"date" => "2018-08-04T04:35:55.398354+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           "country" => "TM", "category" => "6015", "rank" => 298, "ranking_type" => "free"}, {"date" => "2018-08-28T06:14:37.350459+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               "country" => "VC", "category" => "6015", "rank" => 5, "ranking_type" => "free"}, {"date" => "2018-08-28T06:17:50.858974+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 "country" => "VC", "category" => "36", "rank" => 221, "ranking_type" => "free"}, {"date" => "2019-01-17T02:38:13.306294+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   "country" => "LU", "category" => "6015", "rank" => 48, "ranking_type" => "free"}, {"date" => "2019-01-20T05:08:05.852143+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      "country" => "BB", "category" => "6015", "rank" => 13, "ranking_type" => "free"}, {"date" => "2019-01-20T05:10:39.494479+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         "country" => "BB", "category" => "36", "rank" => 737, "ranking_type" => "free"}, {"date" => "2019-02-11T19:07:04.462345+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           "country" => "PW", "category" => "6015", "rank" => 514, "ranking_type" => "free"}, {"date" => "2019-02-11T21:39:47.790558+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               "country" => "TZ", "category" => "36", "rank" => 1363, "ranking_type" => "free"}, {"date" => "2019-02-20T03:19:05.143156+00:00",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  "country" => "GY", "category" => "6015", "rank" => 150, "ranking_type" => "free"}], "all_version_ratings_count" => 1860,
      "current_version_rating" => "3.5", "sdk_activity" => [{"id" => 67, "name" => "AFNetworking",
                                                             "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
                                                             "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Networking"],
                                                             "installed" => true}, {"id" => 99, "name" => "Answers", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                                                    "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                                            "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Analytics"], "installed" => true},
                                                            {"id" => 387, "name" => "BNRDynamicTypeManager", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 457, "name" => "BSKeyboardControls", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 650, "name" => "CXFeedParser", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 714, "name" => "Crashlytics", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["App Performance Management"],
                                                             "installed" => true}, {"id" => 911, "name" => "Fabric", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                                                    "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                                            "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Backend"], "installed" => true},
                                                            {"id" => 1117, "name" => "GoogleAnalytics", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Analytics"], "installed" => true},
                                                            {"id" => 1158, "name" => "GoogleUtilities", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Utilities"], "installed" => true},
                                                            {"id" => 1822, "name" => "Mantle", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Utilities"], "installed" => true},
                                                            {"id" => 1840, "name" => "MBProgressHUD", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true},
                                                            {"id" => 1850, "name" => "MBCircularProgressBar", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 2405, "name" => "PBWebViewController", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 2457, "name" => "pop", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00",
                                                             "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"],
                                                             "installed" => true}, {"id" => 2531, "name" => "PureLayout", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                                                    "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                                            "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true},
                                                            {"id" => 2557, "name" => "RaptureXML", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 2780, "name" => "SDWebImage", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Media"], "installed" => true},
                                                            {"id" => 3176, "name" => "TPKeyboardAvoiding", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true},
                                                            {"id" => 3205, "name" => "UAObfuscatedString", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 3300, "name" => "TTTAttributedLabel", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true},
                                                            {"id" => 3302, "name" => "TUSafariActivity", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 3308, "name" => "UALogger", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 3565, "name" => "XMLDictionary", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 3712, "name" => "Twitter", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
                                                            {"id" => 1032, "name" => "FMDB", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2017-12-11T20:52:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2017-12-11T20:52:42.000-08:00"}], "categories" => ["Backend"], "installed" => true},
                                                            {"id" => 1162, "name" => "Google-AdMob-Ads-SDK", "last_seen_date" => "2019-02-20T16:40:55.000-08:00",
                                                             "first_seen_date" => "2017-12-11T20:52:42.000-08:00", "activities" => [{"type" => "install",
                                                                                                                                     "date" => "2017-12-11T20:52:42.000-08:00"}], "categories" => ["Monetization", "Ad-Mediation"],
                                                             "installed" => true}], "countries_available_in" => ["US", "GB"], "current_version" => "5.4.3",
      "publisher" => {"app_store_id" => 414113285, "platform" => "ios", "id" => 45752, "name" => "Internal
  Revenue Service"}, "taken_down" => false, "support_url" => "https://www.irs.gov/refunds",
      "description" => "Check your refund status, make a payment, find free tax preparation
  assistance, sign up for helpful tax tips, generate a login security code, and follow
  the latest news from the IRS - all in the latest version of IRS2Go.\n\nDownload
  IRS2Go and connect with the IRS whenever you want, wherever you are.\n\nIRS2Go is
  the official app of the Internal Revenue Service.", "current_version_ratings_count" => 164,
      "user_base_by_country" => [{"country_code" => "GB", "country" => "United Kingdom", "user_base" => "weak"},
                                 {"country_code" => "US", "country" => "United States", "user_base" => "strong"}], "first_scraped" => "2015-01-31",
      "app_identifier" => 414113282, "icon_url" => "https://is4-ssl.mzstatic.com/image/thumb/Purple128/v4/1b/66/7a/1b667af9-9bc2-00d3-38c7-4ed393767544/source/100x100bb.jpg",
      "first_scanned_date" => "2017-06-09T22:54:01Z", "original_release_date" => "2011-01-20",
      "versions_history" => [{"version" => "5.0", "released" => "2015-01-31"}, {"version" => "5.1",
                                                                                "released" => "2015-05-11"}, {"version" => "5.1.1", "released" => "2015-06-16"}, {"version" => "5.2",
                                                                                                                                                                  "released" => "2015-08-16"}, {"version" => "5.2.2", "released" => "2016-01-13"}, {"version" => "5.3",
                                                                                                                                                                                                                                                    "released" => "2016-12-11"}, {"version" => "5.3.1", "released" => "2016-12-22"}, {"version" => "5.3.1",
                                                                                                                                                                                                                                                                                                                                      "released" => "2017-11-04"}, {"version" => "5.4", "released" => "2017-12-10"}, {"version" => "5.4.1",
                                                                                                                                                                                                                                                                                                                                                                                                                      "released" => "2017-12-20"}, {"version" => "5.4.2", "released" => "2018-01-25"}, {"version" => "5.4.3",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        "released" => "2018-11-18"}], "id" => 103766, "headquarters" => [{"domain" => "irs.gov",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          "street_number" => nil, "street_name" => "Constitution NW Ave", "sub_premise" => "1111",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          "city" => "Washington", "postal_code" => "20224", "state" => "Washington D.C.", "state_code" => "DC",
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          "country" => "United States", "country_code" => "US", "lat" => "38.89214", "lng" => "-77.02638"}],
      "bundle_identifier" => "gov.irs.IRS2Go", "mobile_priority" => "medium", "ratings_by_country" => [{"current_rating" => 1.0,
                                                                                                        "ratings_current_count" => 1, "ratings_per_day_current_release" => 0.0, "country_code" => "GB",
                                                                                                        "rating" => 0.0, "ratings_count" => 0, "country" => "United Kingdom"}, {"current_rating" => 3.5,
                                                                                                                                                                                "ratings_current_count" => 164, "ratings_per_day_current_release" => 1.0, "country_code" => "US",
                                                                                                                                                                                "rating" => 3.0, "ratings_count" => 1860, "country" => "United States"}], "major_app" => true,
      "all_version_rating" => 3.0, "ratings_history" => [{"start_date" => "2015-03-30T16:54:57.000-07:00",
                                                          "stop_date" => "2015-03-31T01:14:30.000-07:00", "ratings_all_count" => 1217, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2015-04-15T23:49:43.000-07:00", "stop_date" => "2015-04-15T23:49:43.000-07:00",
                                                          "ratings_all_count" => 1220, "ratings_all_stars" => "3.0"}, {"start_date" => "2015-06-02T04:43:01.000-07:00",
                                                                                                                       "stop_date" => "2015-06-02T04:43:01.000-07:00", "ratings_all_count" => 1225, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2015-06-19T13:42:52.000-07:00", "stop_date" => "2015-06-19T13:42:52.000-07:00",
                                                          "ratings_all_count" => 0, "ratings_all_stars" => "3.0"}, {"start_date" => "2015-10-14T17:47:00.000-07:00",
                                                                                                                    "stop_date" => "2015-10-14T17:47:00.000-07:00", "ratings_all_count" => 1227, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2015-08-18T12:29:58.000-07:00", "stop_date" => "2015-12-18T13:39:12.000-08:00",
                                                          "ratings_all_count" => 1226, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-01-19T12:46:40.000-08:00",
                                                                                                                       "stop_date" => "2016-01-19T12:46:40.000-08:00", "ratings_all_count" => 1232, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-01-25T13:15:18.000-08:00", "stop_date" => "2016-01-25T13:15:18.000-08:00",
                                                          "ratings_all_count" => 1238, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-02-01T17:53:09.000-08:00",
                                                                                                                       "stop_date" => "2016-02-01T17:53:09.000-08:00", "ratings_all_count" => 1249, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-02-16T22:27:56.000-08:00", "stop_date" => "2016-02-16T22:27:56.000-08:00",
                                                          "ratings_all_count" => 1264, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-03-04T00:04:30.000-08:00",
                                                                                                                       "stop_date" => "2016-03-04T00:04:30.000-08:00", "ratings_all_count" => 1266, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-03-10T22:51:01.000-08:00", "stop_date" => "2016-03-10T22:51:01.000-08:00",
                                                          "ratings_all_count" => 1269, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-03-21T00:28:25.000-07:00",
                                                                                                                       "stop_date" => "2016-03-21T00:28:25.000-07:00", "ratings_all_count" => 1270, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-03-25T21:42:41.000-07:00", "stop_date" => "2016-03-25T21:42:41.000-07:00",
                                                          "ratings_all_count" => 1272, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-04-01T15:57:43.000-07:00",
                                                                                                                       "stop_date" => "2016-04-01T15:57:43.000-07:00", "ratings_all_count" => 1273, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-04-08T22:33:30.000-07:00", "stop_date" => "2016-04-08T22:33:30.000-07:00",
                                                          "ratings_all_count" => 1275, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-04-16T09:48:50.000-07:00",
                                                                                                                       "stop_date" => "2016-04-16T09:48:50.000-07:00", "ratings_all_count" => 1276, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-04-23T13:20:58.000-07:00", "stop_date" => "2016-04-23T13:20:58.000-07:00",
                                                          "ratings_all_count" => 1277, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-05-07T00:04:44.000-07:00",
                                                                                                                       "stop_date" => "2016-05-07T00:04:44.000-07:00", "ratings_all_count" => 1278, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-05-29T18:42:50.000-07:00", "stop_date" => "2016-07-17T15:46:19.000-07:00",
                                                          "ratings_all_count" => 1279, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-05-13T23:16:52.000-07:00",
                                                                                                                       "stop_date" => "2016-09-02T22:57:33.000-07:00", "ratings_all_count" => 1280, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-09-05T17:34:49.000-07:00", "stop_date" => "2016-09-11T19:18:40.000-07:00",
                                                          "ratings_all_count" => 1281, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-09-17T10:32:34.000-07:00",
                                                                                                                       "stop_date" => "2016-11-26T04:29:55.000-08:00", "ratings_all_count" => 1282, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2016-12-03T04:31:23.000-08:00", "stop_date" => "2016-12-17T15:30:41.000-08:00",
                                                          "ratings_all_count" => 1283, "ratings_all_stars" => "3.0"}, {"start_date" => "2016-12-25T07:13:23.000-08:00",
                                                                                                                       "stop_date" => "2017-01-01T08:02:40.000-08:00", "ratings_all_count" => 1284, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-01-10T10:55:59.000-08:00", "stop_date" => "2017-01-14T19:05:04.000-08:00",
                                                          "ratings_all_count" => 1285, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-01-21T09:52:09.000-08:00",
                                                                                                                       "stop_date" => "2017-01-21T09:52:09.000-08:00", "ratings_all_count" => 1286, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-01-28T09:55:12.000-08:00", "stop_date" => "2017-01-28T09:55:12.000-08:00",
                                                          "ratings_all_count" => 1290, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-02-11T11:21:20.000-08:00",
                                                                                                                       "stop_date" => "2017-02-11T11:21:20.000-08:00", "ratings_all_count" => 1304, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-02-20T20:18:45.000-08:00", "stop_date" => "2017-02-20T20:18:45.000-08:00",
                                                          "ratings_all_count" => 1309, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-02-25T09:29:09.000-08:00",
                                                                                                                       "stop_date" => "2017-02-25T09:29:09.000-08:00", "ratings_all_count" => 1311, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-03-12T20:19:18.000-07:00", "stop_date" => "2017-03-18T11:43:57.000-07:00",
                                                          "ratings_all_count" => 1318, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-03-25T10:40:57.000-07:00",
                                                                                                                       "stop_date" => "2017-03-25T10:40:57.000-07:00", "ratings_all_count" => 1322, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-04-08T21:13:34.000-07:00", "stop_date" => "2017-04-08T21:13:34.000-07:00",
                                                          "ratings_all_count" => 1327, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-06-24T15:49:15.000-07:00",
                                                                                                                       "stop_date" => "2017-08-19T05:53:52.000-07:00", "ratings_all_count" => 1330, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-04-15T11:17:56.000-07:00", "stop_date" => "2017-10-13T05:50:10.000-07:00",
                                                          "ratings_all_count" => 1328, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-05-06T10:39:57.000-07:00",
                                                                                                                       "stop_date" => "2017-10-20T06:04:50.000-07:00", "ratings_all_count" => 1329, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-10-28T05:53:38.000-07:00", "stop_date" => "2017-11-18T16:48:58.000-08:00",
                                                          "ratings_all_count" => 1331, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-11-24T20:52:37.000-08:00",
                                                                                                                       "stop_date" => "2017-12-01T19:46:44.000-08:00", "ratings_all_count" => 1333, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-12-11T10:53:05.000-08:00", "stop_date" => "2017-12-11T19:59:13.000-08:00",
                                                          "ratings_all_count" => 1334, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-12-16T21:00:53.000-08:00",
                                                                                                                       "stop_date" => "2017-12-17T05:26:34.000-08:00", "ratings_all_count" => 1338, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2017-12-24T00:56:16.000-08:00", "stop_date" => "2017-12-24T00:56:16.000-08:00",
                                                          "ratings_all_count" => 1339, "ratings_all_stars" => "3.0"}, {"start_date" => "2017-12-30T12:52:03.000-08:00",
                                                                                                                       "stop_date" => "2017-12-30T17:35:46.000-08:00", "ratings_all_count" => 1345, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-01-06T16:50:45.000-08:00", "stop_date" => "2018-01-07T05:37:35.000-08:00",
                                                          "ratings_all_count" => 1348, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-01-29T19:10:28.000-08:00",
                                                                                                                       "stop_date" => "2018-01-29T19:10:28.000-08:00", "ratings_all_count" => 1381, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-01-30T06:28:20.000-08:00", "stop_date" => "2018-01-30T10:33:40.000-08:00",
                                                          "ratings_all_count" => 1387, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-01-30T11:47:52.000-08:00",
                                                                                                                       "stop_date" => "2018-01-30T11:47:52.000-08:00", "ratings_all_count" => 1390, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-03-02T17:08:53.000-08:00", "stop_date" => "2018-03-02T18:37:45.000-08:00",
                                                          "ratings_all_count" => 1577, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-03-10T01:49:16.000-08:00",
                                                                                                                       "stop_date" => "2018-03-10T01:49:16.000-08:00", "ratings_all_count" => 1592, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-03-17T14:10:42.000-07:00", "stop_date" => "2018-03-17T14:10:42.000-07:00",
                                                          "ratings_all_count" => 1597, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-03-24T06:15:57.000-07:00",
                                                                                                                       "stop_date" => "2018-03-24T06:15:57.000-07:00", "ratings_all_count" => 1604, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-03-31T05:58:10.000-07:00", "stop_date" => "2018-03-31T05:58:10.000-07:00",
                                                          "ratings_all_count" => 1607, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-04-07T13:58:15.000-07:00",
                                                                                                                       "stop_date" => "2018-04-07T13:58:15.000-07:00", "ratings_all_count" => 1620, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-04-14T06:07:21.000-07:00", "stop_date" => "2018-04-14T06:07:21.000-07:00",
                                                          "ratings_all_count" => 1640, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-04-21T05:55:14.000-07:00",
                                                                                                                       "stop_date" => "2018-04-21T05:55:14.000-07:00", "ratings_all_count" => 1652, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-04-29T09:56:16.000-07:00", "stop_date" => "2018-04-29T09:56:16.000-07:00",
                                                          "ratings_all_count" => 1662, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-05-05T06:07:45.000-07:00",
                                                                                                                       "stop_date" => "2018-05-05T06:07:45.000-07:00", "ratings_all_count" => 1669, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-05-12T05:55:39.000-07:00", "stop_date" => "2018-05-12T05:55:39.000-07:00",
                                                          "ratings_all_count" => 1675, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-05-19T18:02:00.000-07:00",
                                                                                                                       "stop_date" => "2018-05-19T18:02:00.000-07:00", "ratings_all_count" => 1679, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-06-03T01:58:11.000-07:00", "stop_date" => "2018-06-03T01:58:11.000-07:00",
                                                          "ratings_all_count" => 1681, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-06-09T09:58:02.000-07:00",
                                                                                                                       "stop_date" => "2018-06-09T17:57:18.000-07:00", "ratings_all_count" => 1682, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-06-16T13:59:56.000-07:00", "stop_date" => "2018-06-16T18:12:41.000-07:00",
                                                          "ratings_all_count" => 1684, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-06-23T22:00:44.000-07:00",
                                                                                                                       "stop_date" => "2018-06-23T22:00:44.000-07:00", "ratings_all_count" => 1688, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-06-30T13:59:04.000-07:00", "stop_date" => "2018-06-30T13:59:04.000-07:00",
                                                          "ratings_all_count" => 1692, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-07-09T16:29:34.000-07:00",
                                                                                                                       "stop_date" => "2018-07-09T16:29:34.000-07:00", "ratings_all_count" => 1695, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-07-16T01:59:18.000-07:00", "stop_date" => "2018-07-16T03:40:43.000-07:00",
                                                          "ratings_all_count" => 1697, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-07-22T01:58:13.000-07:00",
                                                                                                                       "stop_date" => "2018-07-22T05:10:09.000-07:00", "ratings_all_count" => 1698, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-07-29T16:59:04.000-07:00", "stop_date" => "2018-08-05T22:01:44.000-07:00",
                                                          "ratings_all_count" => 1700, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-08-12T05:58:53.000-07:00",
                                                                                                                       "stop_date" => "2018-08-19T09:59:13.000-07:00", "ratings_all_count" => 1702, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-08-26T18:00:53.000-07:00", "stop_date" => "2018-08-27T02:13:10.000-07:00",
                                                          "ratings_all_count" => 1705, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-09-02T05:59:19.000-07:00",
                                                                                                                       "stop_date" => "2018-09-02T11:15:48.000-07:00", "ratings_all_count" => 1707, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-09-10T21:58:42.000-07:00", "stop_date" => "2018-09-11T02:14:42.000-07:00",
                                                          "ratings_all_count" => 1708, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-09-16T09:58:02.000-07:00",
                                                                                                                       "stop_date" => "2018-09-16T11:55:35.000-07:00", "ratings_all_count" => 1709, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-09-23T14:00:17.000-07:00", "stop_date" => "2018-09-23T15:48:42.000-07:00",
                                                          "ratings_all_count" => 1712, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-09-30T13:58:19.000-07:00",
                                                                                                                       "stop_date" => "2018-09-30T19:50:52.000-07:00", "ratings_all_count" => 1711, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-10-14T18:07:11.000-07:00", "stop_date" => "2018-10-14T18:07:11.000-07:00",
                                                          "ratings_all_count" => 1713, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-10-21T18:00:04.000-07:00",
                                                                                                                       "stop_date" => "2018-10-21T18:00:04.000-07:00", "ratings_all_count" => 1714, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-10-28T21:57:25.000-07:00", "stop_date" => "2018-10-28T21:57:25.000-07:00",
                                                          "ratings_all_count" => 1716, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-10-30T22:46:50.000-07:00",
                                                                                                                       "stop_date" => "2018-11-04T09:01:19.000-08:00", "ratings_all_count" => 1715, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-11-15T17:01:06.000-08:00", "stop_date" => "2018-11-15T17:01:06.000-08:00",
                                                          "ratings_all_count" => 1718, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-11-21T09:01:42.000-08:00",
                                                                                                                       "stop_date" => "2018-12-03T09:00:13.000-08:00", "ratings_all_count" => 1723, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-12-10T20:58:17.000-08:00", "stop_date" => "2018-12-10T20:58:17.000-08:00",
                                                          "ratings_all_count" => 1725, "ratings_all_stars" => "3.0"}, {"start_date" => "2018-12-18T11:34:51.000-08:00",
                                                                                                                       "stop_date" => "2018-12-25T20:58:56.000-08:00", "ratings_all_count" => 1729, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2018-12-18T04:58:27.000-08:00", "stop_date" => "2018-12-31T13:00:49.000-08:00",
                                                          "ratings_all_count" => 1728, "ratings_all_stars" => "3.0"}, {"start_date" => "2019-01-16T04:59:24.000-08:00",
                                                                                                                       "stop_date" => "2019-01-26T16:59:25.000-08:00", "ratings_all_count" => 1730, "ratings_all_stars" => "3.0"},
                                                         {"start_date" => "2019-02-03T09:18:20.000-08:00", "stop_date" => "2019-02-03T09:18:20.000-08:00",
                                                          "ratings_all_count" => 1768, "ratings_all_stars" => "3.0"}, {"start_date" => "2019-02-09T16:58:14.000-08:00",
                                                                                                                       "stop_date" => nil, "ratings_all_count" => 1807, "ratings_all_stars" => "3.0"}], "rankings" => {"date" => "2019-02-22T09:58:49.626824",
                                                                                                                                                                                                                       "charts" => [{"category" => "6015", "monthly_change" => 52, "country" => "LR", "rank" => 318,
                                                                                                                                                                                                                                     "ranking_type" => "free", "weekly_change" => -230}, {"category" => "6015", "monthly_change" => nil,
                                                                                                                                                                                                                                                                                          "country" => "PW", "rank" => 20, "ranking_type" => "free", "weekly_change" => 493}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                                                               "monthly_change" => 80, "country" => "BM", "rank" => 514, "ranking_type" => "free", "weekly_change" => -5},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 517, "country" => "UZ", "rank" => 701, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 140, "country" => "PY",
                                                                                                                                                                                                                                                               "rank" => 426, "ranking_type" => "free", "weekly_change" => 131}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => 17, "country" => "FM", "rank" => 84, "ranking_type" => "free", "weekly_change" => 22},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -307, "country" => "AE", "rank" => 784, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 129, "country" => "UG",
                                                                                                                                                                                                                                                               "rank" => 1305, "ranking_type" => "free", "weekly_change" => -67}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                   "monthly_change" => 210, "country" => "KZ", "rank" => 1210, "ranking_type" => "free", "weekly_change" => -977},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 417, "country" => "EC", "rank" => 217, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -126}, {"category" => "6015", "monthly_change" => nil, "country" => "KE",
                                                                                                                                                                                                                                                                "rank" => 1465, "ranking_type" => "free", "weekly_change" => -469}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                     "monthly_change" => 332, "country" => "MX", "rank" => 95, "ranking_type" => "free", "weekly_change" => 45},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => nil, "country" => "ID", "rank" => 529, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => nil}, {"category" => "6015", "monthly_change" => -61, "country" => "CO",
                                                                                                                                                                                                                                                               "rank" => 1031, "ranking_type" => "free", "weekly_change" => -36}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                   "monthly_change" => -10, "country" => "SL", "rank" => 533, "ranking_type" => "free", "weekly_change" => -44},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -221, "country" => "LB", "rank" => 1396, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -149}, {"category" => "6015", "monthly_change" => 129, "country" => "MD",
                                                                                                                                                                                                                                                                "rank" => 1169, "ranking_type" => "free", "weekly_change" => -347}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                     "monthly_change" => 68, "country" => "VC", "rank" => 934, "ranking_type" => "free", "weekly_change" => 65},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => nil, "country" => "TZ", "rank" => 918, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -797}, {"category" => "36", "monthly_change" => 221, "country" => "US",
                                                                                                                                                                                                                                                                "rank" => 2, "ranking_type" => "free", "weekly_change" => 7}, {"category" => "6015", "monthly_change" => -21,
                                                                                                                                                                                                                                                                                                                               "country" => "GW", "rank" => 461, "ranking_type" => "free", "weekly_change" => 64}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                                                                                                    "monthly_change" => 9, "country" => "AR", "rank" => 1066, "ranking_type" => "free", "weekly_change" => 54},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 61, "country" => "KN", "rank" => 928, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -167}, {"category" => "6015", "monthly_change" => 440, "country" => "IN",
                                                                                                                                                                                                                                                                "rank" => 877, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                   "monthly_change" => nil, "country" => "PL", "rank" => 231, "ranking_type" => "free", "weekly_change" => nil},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 368, "country" => "AI", "rank" => 156, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -151}, {"category" => "6015", "monthly_change" => 32, "country" => "JM",
                                                                                                                                                                                                                                                                "rank" => 14, "ranking_type" => "free", "weekly_change" => 2}, {"category" => "6015", "monthly_change" => 9,
                                                                                                                                                                                                                                                                                                                                "country" => "SV", "rank" => 393, "ranking_type" => "free", "weekly_change" => -44}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                                                                                                      "monthly_change" => 43, "country" => "MW", "rank" => 1014, "ranking_type" => "free", "weekly_change" => -36},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -2, "country" => "LT", "rank" => 568, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -89}, {"category" => "6015", "monthly_change" => nil, "country" => "CH",
                                                                                                                                                                                                                                                               "rank" => 636, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => 44, "country" => "AG", "rank" => 332, "ranking_type" => "free", "weekly_change" => -152},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 104, "country" => "GD", "rank" => 849, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -49}, {"category" => "6015", "monthly_change" => nil, "country" => "GY",
                                                                                                                                                                                                                                                               "rank" => 174, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => 261, "country" => "KY", "rank" => 574, "ranking_type" => "free", "weekly_change" => -375},
                                                                                                                                                                                                                                    {"category" => "36", "monthly_change" => nil, "country" => "JM", "rank" => 504, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => 142}, {"category" => "6015", "monthly_change" => nil, "country" => "HK",
                                                                                                                                                                                                                                                               "rank" => 978, "ranking_type" => "free", "weekly_change" => 343}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => 516, "country" => "PH", "rank" => 115, "ranking_type" => "free", "weekly_change" => 23},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -26, "country" => "PA", "rank" => 1153, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -29}, {"category" => "6015", "monthly_change" => 44, "country" => "VE",
                                                                                                                                                                                                                                                               "rank" => 973, "ranking_type" => "free", "weekly_change" => 39}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                 "monthly_change" => 770, "country" => "IE", "rank" => 508, "ranking_type" => "free", "weekly_change" => 611},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 21, "country" => "VG", "rank" => 284, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => 20}, {"category" => "6015", "monthly_change" => 102, "country" => "HR",
                                                                                                                                                                                                                                                              "rank" => 858, "ranking_type" => "free", "weekly_change" => 101}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                 "monthly_change" => 802, "country" => "JO", "rank" => 222, "ranking_type" => "free", "weekly_change" => 631},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 200, "country" => "AL", "rank" => 746, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -121}, {"category" => "6015", "monthly_change" => 501, "country" => "CA",
                                                                                                                                                                                                                                                                "rank" => 516, "ranking_type" => "free", "weekly_change" => 173}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                   "monthly_change" => 7, "country" => "EG", "rank" => 1483, "ranking_type" => "free", "weekly_change" => -9},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -20, "country" => "MN", "rank" => 1282, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -7}, {"category" => "6015", "monthly_change" => 33, "country" => "NG",
                                                                                                                                                                                                                                                              "rank" => 822, "ranking_type" => "free", "weekly_change" => -405}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => nil, "country" => "PK", "rank" => 345, "ranking_type" => "free", "weekly_change" => 1364},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -680, "country" => "GM", "rank" => 1454, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -6}, {"category" => "6015", "monthly_change" => nil, "country" => "QA",
                                                                                                                                                                                                                                                              "rank" => 445, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                 "monthly_change" => nil, "country" => "TR", "rank" => 491, "ranking_type" => "free", "weekly_change" => nil},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 381, "country" => "RO", "rank" => 423, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => 8}, {"category" => "6015", "monthly_change" => 396, "country" => "NI",
                                                                                                                                                                                                                                                             "rank" => 51, "ranking_type" => "free", "weekly_change" => 377}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                               "monthly_change" => 444, "country" => "FJ", "rank" => 973, "ranking_type" => "free", "weekly_change" => 67},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 345, "country" => "AM", "rank" => 856, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -109}, {"category" => "6015", "monthly_change" => -71, "country" => "TM",
                                                                                                                                                                                                                                                                "rank" => 1456, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                    "monthly_change" => 48, "country" => "YE", "rank" => 254, "ranking_type" => "free", "weekly_change" => 52},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 6, "country" => "CL", "rank" => 1260, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -12}, {"category" => "6015", "monthly_change" => 2, "country" => "MR",
                                                                                                                                                                                                                                                               "rank" => 1396, "ranking_type" => "free", "weekly_change" => -382}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                    "monthly_change" => 9, "country" => "US", "rank" => 1, "ranking_type" => "free", "weekly_change" => 0},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -46, "country" => "MK", "rank" => 583, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => 6}, {"category" => "6015", "monthly_change" => nil, "country" => "NZ",
                                                                                                                                                                                                                                                             "rank" => 1341, "ranking_type" => "free", "weekly_change" => -139}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => 117, "country" => "DE", "rank" => 619, "ranking_type" => "free", "weekly_change" => nil},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 31, "country" => "DM", "rank" => 53, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -15}, {"category" => "6015", "monthly_change" => nil, "country" => "CZ",
                                                                                                                                                                                                                                                               "rank" => 304, "ranking_type" => "free", "weekly_change" => 1159}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                   "monthly_change" => nil, "country" => "BH", "rank" => 1465, "ranking_type" => "free", "weekly_change" => -9},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 39, "country" => "CR", "rank" => 662, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => 100}, {"category" => "6015", "monthly_change" => nil, "country" => "RU",
                                                                                                                                                                                                                                                               "rank" => 1169, "ranking_type" => "free", "weekly_change" => 112}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                   "monthly_change" => nil, "country" => "UY", "rank" => 879, "ranking_type" => "free", "weekly_change" => nil},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 301, "country" => "DO", "rank" => 36, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => 19}, {"category" => "6015", "monthly_change" => -231, "country" => "LC",
                                                                                                                                                                                                                                                              "rank" => 1109, "ranking_type" => "free", "weekly_change" => -229}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                   "monthly_change" => 42, "country" => "ML", "rank" => 946, "ranking_type" => "free", "weekly_change" => -69},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -5, "country" => "CV", "rank" => 358, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -45}, {"category" => "6015", "monthly_change" => -25, "country" => "PT",
                                                                                                                                                                                                                                                               "rank" => 392, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => 48, "country" => "BG", "rank" => 788, "ranking_type" => "free", "weekly_change" => -91},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 264, "country" => "DZ", "rank" => 586, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -4}, {"category" => "6015", "monthly_change" => nil, "country" => "FI",
                                                                                                                                                                                                                                                              "rank" => 1322, "ranking_type" => "free", "weekly_change" => nil}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => 1158, "country" => "BZ", "rank" => 159, "ranking_type" => "free", "weekly_change" => 974},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 201, "country" => "GH", "rank" => 1104, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => 193}, {"category" => "6015", "monthly_change" => -13, "country" => "GT",
                                                                                                                                                                                                                                                               "rank" => 466, "ranking_type" => "free", "weekly_change" => 0}, {"category" => "6015", "monthly_change" => 5,
                                                                                                                                                                                                                                                                                                                                "country" => "HN", "rank" => 336, "ranking_type" => "free", "weekly_change" => 14}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                                                                                                     "monthly_change" => -94, "country" => "SK", "rank" => 214, "ranking_type" => "free", "weekly_change" => 926},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -1257, "country" => "BB", "rank" => 1371, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -266}, {"category" => "6015", "monthly_change" => 0, "country" => "TT",
                                                                                                                                                                                                                                                                "rank" => 710, "ranking_type" => "free", "weekly_change" => 32}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                  "monthly_change" => -442, "country" => "TC", "rank" => 1310, "ranking_type" => "free", "weekly_change" => -201},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => 94, "country" => "BR", "rank" => 1258, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 223, "country" => "BS",
                                                                                                                                                                                                                                                               "rank" => 302, "ranking_type" => "free", "weekly_change" => -124}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                   "monthly_change" => 308, "country" => "PE", "rank" => 185, "ranking_type" => "free", "weekly_change" => -24},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -501, "country" => "IL", "rank" => 890, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => 1}, {"category" => "6015", "monthly_change" => 76, "country" => "BO",
                                                                                                                                                                                                                                                             "rank" => 946, "ranking_type" => "free", "weekly_change" => -423}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                 "monthly_change" => 195, "country" => "MG", "rank" => 1104, "ranking_type" => "free", "weekly_change" => nil},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => nil, "country" => "IT", "rank" => 671, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => nil}, {"category" => "6015", "monthly_change" => 1, "country" => "SN",
                                                                                                                                                                                                                                                               "rank" => 933, "ranking_type" => "free", "weekly_change" => 62}, {"category" => "6015",
                                                                                                                                                                                                                                                                                                                                 "monthly_change" => nil, "country" => "ES", "rank" => 1140, "ranking_type" => "free", "weekly_change" => -1},
                                                                                                                                                                                                                                    {"category" => "6015", "monthly_change" => -340, "country" => "MZ", "rank" => 1453, "ranking_type" => "free",
                                                                                                                                                                                                                                     "weekly_change" => -244}, {"category" => "6015", "monthly_change" => 356, "country" => "AO",
                                                                                                                                                                                                                                                                "rank" => 222, "ranking_type" => "free", "weekly_change" => 329}]}, "current_version_release_date" => "2018-11-18",
      "platform" => "ios", "categories" => [{"type" => "primary", "name" => "Finance", "id" => 6015}],
      "last_scanned_date" => "2019-02-21T00:40:55Z", "permissions" => ["Fabric", "CFBundleIcons",
                                                                       "CFBundleInfoDictionaryVersion", "DTXcodeBuild", "CFBundleSupportedPlatforms", "CFBundleIdentifier",
                                                                       "DTSDKName", "DTPlatformVersion", "CFBundleIcons~ipad", "CFBundleShortVersionString",
                                                                       "UILaunchImages", "NSLocationWhenInUseUsageDescription", "CFBundleDisplayName",
                                                                       "BuildMachineOSBuild", "DTAppStoreToolsBuild", "UILaunchStoryboardName", "MinimumOSVersion",
                                                                       "UIViewControllerBasedStatusBarAppearance", "CFBundleVersion", "CFBundleExecutable",
                                                                       "UIMainStoryboardFile", "UIDeviceFamily", "DTPlatformBuild", "UIRequiredDeviceCapabilities",
                                                                       "UIStatusBarStyle", "DTXcode", "CFBundleDevelopmentRegion", "DTPlatformName", "NSAppTransportSecurity",
                                                                       "UISupportedInterfaceOrientations~ipad", "UISupportedInterfaceOrientations", "DTCompiler",
                                                                       "CFBundleSignature", "LSRequiresIPhoneOS", "DTSDKBuild", "LSApplicationQueriesSchemes",
                                                                       "CFBundleName", "CFBundlePackageType"], "name" => "IRS2Go", "price" => 0, "seller_url" => "https://www.irs.gov/irs2go",
      "in_app_purchases" => false, "user_base" => "strong", "seller" => "Internal Revenue Service"}]
  end

  def mock_app_last_update_date
    '2018-11-18'
  end

  def mock_app_latest_update
    96
  end

  def mock_app_sdks
    [{"id" => 67, "name" => "AFNetworking", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Networking"], "installed" => true},
     {"id" => 99, "name" => "Answers", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Analytics"], "installed" => true},
     {"id" => 387, "name" => "BNRDynamicTypeManager", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 457, "name" => "BSKeyboardControls", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 650, "name" => "CXFeedParser", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 714, "name" => "Crashlytics", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["App Performance Management"], "installed" => true}, {"id" => 911, "name" => "Fabric", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Backend"], "installed" => true},
     {"id" => 1117, "name" => "GoogleAnalytics", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Analytics"], "installed" => true},
     {"id" => 1158, "name" => "GoogleUtilities", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Utilities"], "installed" => true},
     {"id" => 1822, "name" => "Mantle", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Utilities"], "installed" => true},
     {"id" => 1840, "name" => "MBProgressHUD", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true},
     {"id" => 1850, "name" => "MBCircularProgressBar", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 2405, "name" => "PBWebViewController", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 2457, "name" => "pop", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true}, {"id" => 2531, "name" => "PureLayout", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true},
     {"id" => 2557, "name" => "RaptureXML", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 2780, "name" => "SDWebImage", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["Media"], "installed" => true},
     {"id" => 3176, "name" => "TPKeyboardAvoiding", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true},
     {"id" => 3205, "name" => "UAObfuscatedString", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 3300, "name" => "TTTAttributedLabel", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => ["UI"], "installed" => true},
     {"id" => 3302, "name" => "TUSafariActivity", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 3308, "name" => "UALogger", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 3565, "name" => "XMLDictionary", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 3712, "name" => "Twitter", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2016-12-25T08:59:42.000-08:00", "activities" => [{"type" => "install", "date" => "2016-12-25T08:59:42.000-08:00"}], "categories" => nil, "installed" => true},
     {"id" => 1032, "name" => "FMDB", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2017-12-11T20:52:42.000-08:00", "activities" => [{"type" => "install", "date" => "2017-12-11T20:52:42.000-08:00"}], "categories" => ["Backend"], "installed" => true},
     {"id" => 1162, "name" => "Google-AdMob-Ads-SDK", "last_seen_date" => "2019-02-20T16:40:55.000-08:00", "first_seen_date" => "2017-12-11T20:52:42.000-08:00", "activities" => [{"type" => "install", "date" => "2017-12-11T20:52:42.000-08:00"}], "categories" => ["Monetization", "Ad-Mediation"], "installed" => true}]
  end

  def mock_app_sdk_installed
    26
  end

  def mock_app_sdk_uninstalled
    0
  end

  def mock_app_installed_sdk_categories
    {"Networking" => 1, "Analytics" => 2, "App Performance Management" => 1, "Backend" => 2, "Utilities" => 2, "UI" => 5, "Media" => 1, "Monetization" => 1, "Ad-Mediation" => 1}
  end

  def mock_app_categories
    ["Finance"]
  end

  def mock_app_uninstalled_sdk_categories
    {"Networking" => 1, "Analytics" => 2, "App Performance Management" => 1, "Backend" => 2, "Utilities" => 2, "UI" => 5, "Media" => 1, "Monetization" => 1, "Ad-Mediation" => 1}
  end

  def mock_app_advertising_creatives
    advertising_creatives = [
        {ad_url: 'https://ms-halo-2.s3.amazonaws.com/assets/5b5a0570e611f12baf29091f8b778527d1a805a3.mp4',
         ad_date: '2018-11-18'},
        {ad_url: 'https://ms-halo-2.s3.amazonaws.com/assets/1f360ae367a8c18120e43e8c6233cf361013ac2e.mp4',
         ad_date: '2018-10-18'},
        {ad_url: 'https://ms-halo-2.s3.amazonaws.com/assets/ee28a148903f31799c20e6afa3e41623d2a9102e.mp4',
         ad_date: '2018-09-18'},
        {ad_url: 'https://ms-halo-2.s3.amazonaws.com/assets/62f754c27a9c16d77946dc5e54b9529af4e55705.mp4',
         ad_date: '2018-10-18'},
        {ad_url: 'https://ms-halo-2.s3.amazonaws.com/assets/ee28a148903f31799c20e6afa3e41623d2a9102e.mp4',
         ad_date: '2018-09-18'},
        {ad_url: 'https://ms-halo-2.s3.amazonaws.com/assets/5b5a0570e611f12baf29091f8b778527d1a805a3.mp4',
         ad_date: '2018-11-18'},
        {ad_url: 'https://ms-halo-2.s3.amazonaws.com/assets/1f360ae367a8c18120e43e8c6233cf361013ac2e.mp4',
         ad_date: '2018-10-18'}
    ]
    advertising_creatives.map {|ad| OpenStruct.new(ad)}
  end

end