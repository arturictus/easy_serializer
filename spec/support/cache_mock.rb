class CacheMock
  def self.fetch(obj, opts = {}, &block)
    :cached
  end
end
