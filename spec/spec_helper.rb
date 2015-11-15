$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
# $LOAD_PATH.unshift File.expand_path('../support', __FILE__)
require 'easy_serializer'
require 'pry'

[
  "./spec/support/serializers/nested_serializer.rb",
  "./spec/support/serializers/polymorphic_subject.rb",
  "./spec/support/serializers/polymorphic_subject_serializer.rb",
  "./spec/support/serializers/polymophic_serializer.rb"
].each{ |f| require f }
# Dir['./spec/support/serializers/*.rb'].each do |f|
#   autoload File.basename(f, '.*').classify.to_sym, f.gsub(/\A.\/spec\/support\/|.rb/, '')
# end
