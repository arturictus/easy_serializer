$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'easy_serializer'
Dir['./serializers/**/*.rb'].each{ |f| require f }
