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
      if metadata.is_a?(EasySerializer::Collection)
        Collection.new(self).execute
      elsif metadata.serializer?
        Serializer.new(self).execute
      else
        Method.new(self).execute
      end
    end
  end
end

require 'easy_serializer/cacher/collection'
require 'easy_serializer/cacher/method'
require 'easy_serializer/cacher/serializer'
