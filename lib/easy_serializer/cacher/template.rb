module EasySerializer
  class Cacher
    class Template
      attr_reader :serializer, :metadata

      def initialize(serializer, metadata)
        @serializer = serializer
        @metadata = metadata
      end

      def self.call(*args)
        new(*args).execute
      end
    end
  end
end
