# RegGen

Generate a sample character string from a pattern like a regular expression pattern.
ATTENTION: Escape symbol "\" may not function properly...

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reg_gen', :git => 'git://github.com/yamahei/reg_gen.git',
```

## Usage

```ruby
puts RegGen.new("0[89]0-[0-9]{3,4}-[0-9]{4}").gen
#=> 090-936-6615
puts RegGen.new("[a-z][._a-z0-9]{5,8}[a-z0-9]@(hoge|fuga).(co.jp|jp|com)").gen
#=> w.9grw6f7@hoge.com
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yamahei/reg_gen. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RegGen project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/yamahei/reg_gen/blob/master/CODE_OF_CONDUCT.md).
