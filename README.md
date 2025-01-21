# Esse Hooks Extension

This gem is part of the [esse](https://github.com/marcosgz/esse) project. It provides a plugin to add hooks to the [esse-active_record](https://github.com/marcosgz/esse-active_record) and [esse-sequel](https://github.com/marcosgz/esse-sequel) plugins.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'esse-hooks'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install esse-hooks

## Usage

To use the hooks, you need to include the mixin in your module or class and define the hooks you want to use.

```ruby
module Esse::ActiveRecord::Hooks
  include Esse::Hooks[store_key: :esse_active_record_hooks]
end
```

Now you can use the hooks to change activeness of the indexing process.

```ruby
Esse::ActiveRecord::Hooks.disable!
Esse::ActiveRecord::Hooks.with_indexing do
  10.times { User.create! }
end

Esse::ActiveRecord::Hooks.enable!
Esse::ActiveRecord::Hooks.without_indexing do
  10.times { User.create! }
end
```

or by some specific list of index or index's repository

```ruby
Esse::ActiveRecord::Hooks.disable!(UsersIndex.repo)
Esse::ActiveRecord::Hooks.with_indexing(AccountsIndex, UsersIndex.repo) do
  10.times { User.create! }
end
Esse::ActiveRecord::Hooks.enable!(UsersIndex.repo)
Esse::ActiveRecord::Hooks.without_indexing(AccountsIndex, UsersIndex.repo) do
  10.times { User.create! }
end
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake none` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/marcosgz/esse-hooks.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
