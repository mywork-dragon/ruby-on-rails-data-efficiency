namespace 'db' do
  desc 'Delete all records created by seeding the db. Faster than db:reset or db:create db:schema:load'
  task unseed: [:environment] do
    IosAppCategory.destroy_all
    AndroidAppCategory.destroy_all
    MicroProxy.destroy_all
    AppStore.destroy_all
    IosDeveloper.destroy_all
    IosApp.destroy_all
    AndroidDeveloper.destroy_all
    AndroidApp.destroy_all
    Company.destroy_all
    Website.destroy_all
    ClearbitContact.destroy_all
    DomainDatum.destroy_all
  end
end
