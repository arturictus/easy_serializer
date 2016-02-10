module EasySerializer
  class Option < Contextuable
    defaults cache_options: {}
  end
  class RootCacheOption < Contextuable
    aliases :cache_key, :key
    defaults root_call: true
    def cache_options
      args.except(:block, :cache_key, :root_call, :serializer, :key)
    end
  end
end
