require 'google_drive'
require 'sequel'

Dir[File.dirname(__FILE__) + '/fence/*.rb'].each do |file|
  require file
end