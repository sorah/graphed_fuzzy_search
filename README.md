# GraphedFuzzySearch: filter items like Slack switcher, Atom command palette can


``` ruby
s = GraphedFuzzySearch.new(%w(john-appleseed john-doe jonathan-doe alice-eve eve-doe))
p s.query('d') #=> ["john-doe", "jonathan-doe", "eve-doe"]
p s.query('dj') #=> ["john-doe", "jonathan-doe"]
p s.query('djoh') #=> ["john-doe"]
p s.query('a') #=> ["alice-eve", "john-appleseed"]
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'graphed_fuzzy_search'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install graphed_fuzzy_search

## Usage

### Basic

``` ruby
s = GraphedFuzzySearch.new(%w(john-appleseed john-doe jonathan-doe alice-eve eve-doe))
p s.query('d') #=> ["john-doe", "jonathan-doe", "eve-doe"]
p s.query('dj') #=> ["john-doe", "jonathan-doe"]
p s.query('djoh') #=> ["john-doe"]
p s.query('a') #=> ["alice-eve", "john-appleseed"]
```

### Multiple attributes

``` ruby
Item = Struct.new(:name, :email)
items = [Item.new('John Doe', 'john-doe@example.com')]
s = GraphedFuzzySearch.new(items, attributes: %i(name email))
# Hint: default +attributes:+ is %i(name)
```

### Custom tokenize

``` ruby
p GraphedFuzzySearch.new(["token_one token_two"]).query('one') #=> ["token_one token_two"]
p GraphedFuzzySearch.new(["token_one token_two"], token_regex: /\w+/).query('one') #=> []
```

## Internal

- index
  1. Split into tokens (substring determined by `token_regex` defaults to `/[^\p{Punct}\p{Space}]+/`)
  2. construct a trie for tokens. each trie is independent for each item.
- query
  1. walk all tries by every character of a given query.

```
Items:
  ax-by
  cy-ax
  by
  bye

Tokens:
  ax by
  cy ax
  by
  bye

Tries:
  a->x b->y, a->b x->b, b->a y->a
  c->y a->x, c->a y->a, a->c x->c
  b->y
  b->y->e
```

## Plans

Pull Requests are welcomed.

- Dump/Load an index (tree)
- Compressing an index

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sorah/graphed_fuzzy_search.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
