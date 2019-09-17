require '/varys/lib/tasks/one_off/fix_categories_task'

namespace 'apps_categories' do

  desc 'Fix all the categories for android and ios apps'
  task fix_all: [:environment] do |task|
    FixCategoriesTask.new.queue_apps
  end

  desc 'Fix the categories for android apps'
  task fix_android: [:environment] do |task|
    FixCategoriesTask.new.queue_android_apps
  end

  desc 'Fix the categories for ios apps'
  task fix_ios: [:environment] do |task|
    FixCategoriesTask.new.queue_ios_apps
  end

end
