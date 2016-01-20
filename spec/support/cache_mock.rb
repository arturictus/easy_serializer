class CacheMock
  def self.fetch(name, &block)
    :cached
  end
end
