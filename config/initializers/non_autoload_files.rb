# Manually load non-autoloaded files here (ones that don't follow the 'my_class.rb' <==> MyClass convention)

Dir["#{Rails.root}/lib/non_autoload/*.rb"].each {|file| require file }