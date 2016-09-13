module EasySerializer
  Collection  = Struct.new(:name, :_options, :block) do
    def options
      received_opts.merge(collection: true)
    end

    def received_opts
      _options || {}
    end
  end
end
