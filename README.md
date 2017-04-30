# Fluff

Runs RSpec in parallel and optionally displays the results on a web UI.

![screenshot](https://github.com/bagilevi/fluff-web-ui/raw/master/docs/screenshot.png "Screenshot")

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluff'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluff

For instructions to install the Web UI, see: [fluff-web-ui](https://github.com/bagilevi/fluff-web-ui#installation).

## Usage

Configure using the following environment variables.

Set the database template:

    FLUFF_DB_URL_TEMPLATE=postgres://myuser:mypass@localhost/myapp_test_%{index}

Specify how many processes to run in parallel:

    FLUFF_PARALLELISM=4

If you would like to see the failures in the Web UI then set the same Redis URL
you have configured for the Web UI. If you don't set this, RSpec will report using
the `progress` formatter.

    FLUFF_REDIS_URL=redis://localhost:6379

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bagilevi/fluff.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
