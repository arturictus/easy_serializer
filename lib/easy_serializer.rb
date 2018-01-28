require "easy_serializer/version"

module EasySerializer
  def self.setup
    yield self
  end

  def self.perform_caching=(val)
    @perform_caching = val
  end

  def self.perform_caching
    return @perform_caching if defined?(@perform_caching)
    false
  end

  def self.cache=(val)
    @cache = val
  end

  def self.cache
    return @cache if defined?(@cache)
    false
  end

end
require 'easy_serializer/helpers'
require 'easy_serializer/field'
require 'easy_serializer/cacher'
require 'easy_serializer/root_cacher'
require 'easy_serializer/attribute'
require 'easy_serializer/attribute_serializer'
require 'easy_serializer/cache_output'
require 'easy_serializer/collection'
require 'easy_serializer/base'
