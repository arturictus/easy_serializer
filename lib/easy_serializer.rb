require "easy_serializer/version"
require 'active_support/all'

module EasySerializer
  include ActiveSupport::Configurable
  extend ActiveSupport::Autoload

  def self.setup
    yield self
  end

  config_accessor(:perform_caching) { false }
  config_accessor(:cache)

  autoload :Helpers
  autoload :Cacher
  autoload :Attribute
  autoload :Base
  autoload :CacheOutput
end
