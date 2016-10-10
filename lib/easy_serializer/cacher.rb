module EasySerializer
  class Cacher
    attr_reader :serializer, :metadata
    def initialize(serializer, metadata)
      @serializer = serializer
      @metadata = metadata
    end

    def execute
      CacheOutput.new(_execute)
    end

    private

    def _execute
      strategy = if metadata.is_a?(EasySerializer::Collection)
                   Collection
                 elsif metadata.serializer?
                   Serializer
                 else
                   Method
                 end
      strategy.call(serializer, metadata)
    end
  end
end

require 'easy_serializer/cacher/template'
require 'easy_serializer/cacher/collection'
require 'easy_serializer/cacher/method'
require 'easy_serializer/cacher/serializer'
