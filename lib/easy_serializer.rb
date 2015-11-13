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

require 'easy_serializer/base'
