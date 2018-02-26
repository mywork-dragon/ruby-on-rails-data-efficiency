module SdkHotStoreSchema

  def sdk_schema
    @@SDK_SCHEMA
  end

  @@CATEGORIES_SCHEMA = {
    "name"=> String,
    "id"=> Integer,
    "created_at"=> String,
    "updated_at"=> String
  }

  @@SDK_SCHEMA = {
    "categories" => [ @@CATEGORIES_SCHEMA ],
    "openSource" => TrueClass,
    "icon" => String,
    "summary" => String,
    "id" => Integer,
    "platform" => String,
    "website" => String,
    "name" => String
  }

end