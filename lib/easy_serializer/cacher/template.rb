module EasySerializer
  class Cacher
    class Template
      attr_reader :cacher
      delegate :serializer, :metadata, to: :cacher
      def initialize(cacher)
        @cacher = cacher
      end

      def self.call(cacher)
        new(cacher).execute
      end
    end
  end
end
