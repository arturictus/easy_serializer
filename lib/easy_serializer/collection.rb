module EasySerializer
  class Collection < Field
    attr_reader :_options, :name, :block
    def initialize(name, options, block)
      @name = name
      @_options = options
      @block = block
    end

    def options
      received_opts.merge(collection: true)
    end

    def send_method(obj)
      obj.send(name).to_a
    end

    def received_opts
      _options || {}
    end

  end
end
