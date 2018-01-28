require 'simplecov'
require 'coveralls'
require "codeclimate-test-reporter"

SimpleCov.start
Coveralls.wear!
CodeClimate::TestReporter.start
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'dystruct'
require 'easy_serializer'
require 'pry'

[
  "./spec/support/serializers/nested_serializer",
  "./spec/support/serializers/polymorphic_subject",
  "./spec/support/serializers/polymorphic_subject_serializer",
  "./spec/support/serializers/polymophic_serializer",
  'support/serializers/nested_serializer',
  "./spec/support/cache_mock",
].each{ |f| require f }
