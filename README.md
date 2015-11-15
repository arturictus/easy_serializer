# EasySerializer

[ ![Codeship Status for arturictus/easy_serializer](https://codeship.com/projects/5a101d20-6dda-0133-b7b2-666194911eaf/status?branch=master)](https://codeship.com/projects/115737)
[![Code Climate](https://codeclimate.com/github/arturictus/easy_serializer/badges/gpa.svg)](https://codeclimate.com/github/arturictus/easy_serializer)
[![Test Coverage](https://codeclimate.com/github/arturictus/easy_serializer/badges/coverage.svg)](https://codeclimate.com/github/arturictus/easy_serializer/coverage)

Semantic serializer for making easy serializing objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'easy_serializer'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install easy_serializer

## Usage

example:
_serializer:_
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
            serializer: proc {|serializer| serializer.serializer_for_subject },
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
PolymorphicSerializer.new(Polymorphic.last).serialize
# => Hash with the object serialized  
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/easy_serializer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
