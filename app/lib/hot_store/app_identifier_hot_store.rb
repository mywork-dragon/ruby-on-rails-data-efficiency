class AppIdentifierHotStore < HotStore

  def write(platform, app_identifier, id)
    puts "**********************************************"
    puts "Received #{platform}, #{app_identifier}, #{id}"
    true
  end
end
