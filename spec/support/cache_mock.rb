class CacheMock
  def self.fetch(obj, opts = {}, &block)
    :cached
  end
end
class CacheMockExplicid
  def self.fetch(obj, opts = {}, &block)
    yield
  end
end
