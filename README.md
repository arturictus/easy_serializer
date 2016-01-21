# EasySerializer

[ ![Codeship Status for arturictus/easy_serializer](https://codeship.com/projects/5a101d20-6dda-0133-b7b2-666194911eaf/status?branch=master)](https://codeship.com/projects/115737)
[![Code Climate](https://codeclimate.com/github/arturictus/easy_serializer/badges/gpa.svg)](https://codeclimate.com/github/arturictus/easy_serializer)
[![Test Coverage](https://codeclimate.com/github/arturictus/easy_serializer/badges/coverage.svg)](https://codeclimate.com/github/arturictus/easy_serializer/coverage)

Semantic serializer for making easy serializing objects.

features:
- Nice and simple serialization DSL.
- Cache helpers to use with your favorite adapter like rails cache.

Advantages:
- Separated responsibility from Model class and serialization allowing multiple serializers for the same Model class, very useful for API versioning.
- In contraposition with active model serializers with EasySerializer you can serialize any object responding to the methods you want to serialize.
- EasySerializer is an small library with few dependencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_serializer

Add the configuration file:

**Only if you need caching.**

_If your are in a Rails environment place this file at config/initializers_

```ruby
EasySerializer.setup do |config|
  # = perform_caching
  #
  # Enable o disable caching.
  # default: false
  #
  # config.perform_caching = true

  # = cache
  #
  # Set your caching tool for the serializer
  # must respond to fetch(obj, opts, &block) like Rails Cache.
  # default: nil
  #
  # config.cache = Rails.cache
end
```

## Usage

### Simple example:

```ruby
user = OpenStruct.new(name: 'John', surname: 'Doe')

class UserSerializer < EasySerializer::Base
  attributes :name, :surname
end

UserSerializer.call(user)
# =>
{
  name: 'John',
  surname: 'Doe'
}
```
**Using blocks:**

```ruby
class UserSerializer < EasySerializer::Base
  attribute(:name) { |user| user.name.capitalize }
  attribute(:surname) { |user| user.surname.capitalize }
end
```

**Changing keys:**

```ruby
class UserSerializer < EasySerializer::Base
  attribute :name, key: :named
  attribute(:surname, key: :lastname) { |user| user.surname.capitalize }
end
```

### Serializing attributes with serializer

```ruby
user = OpenStruct.new(
  name: 'John',
  surname: 'Doe',
  address: OpenStruct.new(
    street: 'Happy street',
    country: 'Wonderland'
  )
)

class AddressSerializer < EasySerializer::Base
  attributes :street, :country
end

class UserSerializer < EasySerializer::Base
  attributes :name, :surname
  collection :address, serializer: AddressSerializer
end

UserSerializer.call(user)
# =>
{
  name: 'John',
  surname: 'Doe',
  address: {
    street: 'Happy street',
    country: 'Wonderland'
  }
}
```

**Removing keys from nested hashes:**

```ruby
class UserSerializer < EasySerializer::Base
  attribute :name, :lastname
  attribute :address,
            key: false,
            serializer: AddressSerializer
end
UserSerializer.call(user)
# =>
{
  name: 'John',
  surname: 'Doe',
  street: 'Happy street',
  country: 'Wonderland'
}
```

**Serializer option accepts a Proc:**

```ruby
class UserSerializer < EasySerializer::Base
  attributes :name, :surname
  attribute :address,
            serializer: proc { |serializer| "#{serializer.klass_ins.name}Serializer" },
            cache: true
end
```

### Collection Example:

```ruby
user = OpenStruct.new(
  name: 'John',
  surname: 'Doe',
  emails: [
    OpenStruct.new(address: 'hello@email.com', type: 'work')
  ]
)

class EmailSerializer < EasySerializer::Base
  attributes :address, :type
end

class UserSerializer < EasySerializer::Base
  attributes :name, :surname
  collection :emails, serializer: EmailSerializer
end

UserSerializer.call(user)
# =>
{
  name: 'John',
  surname: 'Doe',
  emails: [ { address: 'hello@email.com', type: 'work' } ]
}
```

### Cache

**Important** cache will only work if is set in the configuration file.

**Caching the serialized object:**

Serialization will happen only once and the result hash will be stored in the cache.

```ruby
class UserSerializer < EasySerializer::Base
  cache true
  attributes :name, :surname
end
```

**Caching attributes:**

Attributes can be cached independently.

```ruby
class UserSerializer < EasySerializer::Base
  attributes :name, :surname
  attribute :costly_query, cache: true
end
```

of course it works with blocks:

```ruby
class UserSerializer < EasySerializer::Base
  attributes :name, :surname
  attribute(:costly_query, cache: true) do |user|
    user.best_friends
  end
end
```

**Caching Collections:**

Cache will try to fetch the cached object in the collection **one by one, the whole collection is not cached**.

```ruby
class UserSerializer < EasySerializer::Base
  attributes :name, :surname
  collection :address, serializer: AddressSerializer, cache: true
end
```

### Complex example using all features:

```ruby
class PolymorphicSerializer < EasySerializer::Base
  cache true
  attribute :segment_type do |object|
    object.subject.class.name.demodulize
  end
  attribute :segment_id do |object|
    object.id
  end
  attributes :initial_date,
             :end_date

  attribute :subject,
            key: false,
            serializer: proc { |serializer| serializer.serializer_for_subject },
            cache: true
  collection :elements, serializer: ElementsSerializer, cache: true

  def serializer_for_subject
    namespace = self.class.name.gsub(self.class.name.demodulize, '')
    object_name = klass_ins.subject_type.demodulize
    "#{namespace}#{object_name}Serializer".constantize
  end
end
```

```ruby
PolymorphicSerializer.call(Polymorphic.last)
# => Hash with the object serialized
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/arturictus/easy_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
