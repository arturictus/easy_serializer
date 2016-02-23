require "easy_serializer/version"
require 'active_support/all'

module EasySerializer
  include ActiveSupport::Configurable

  def self.setup
    yield self
  end

  config_accessor(:perform_caching) { false }
  config_accessor(:cache)
end

require 'easy_serializer/helpers'
require 'easy_serializer/cacher'
require 'easy_serializer/attribute'
require 'easy_serializer/base'
