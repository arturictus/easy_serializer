module EasySerializer
  class CacheRef
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
      if metadata.is_a?(Collection)
        CollectionCacher.new(self).execute
      elsif metadata.serializer?
        SerializerCacher.new(self).execute
      else
        MethodCacher.new(self).execute
      end
    end
  end
end
