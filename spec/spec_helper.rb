$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'easy_serializer'
require 'pry'
[
  "./spec/support/serializers/nested_serializer.rb",
  "./spec/support/serializers/polymorphic_subject.rb",
  "./spec/support/serializers/polymorphic_subject_serializer.rb",
  "./spec/support/serializers/polymophic_serializer.rb",
  "./spec/support/cache_mock",
].each{ |f| require f }
