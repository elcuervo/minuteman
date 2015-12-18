![Minuteman](http://elcuervo.github.com/minuteman/img/minuteman-readme.png)

# Minuteman
[![Code Climate](https://codeclimate.com/github/elcuervo/minuteman.png)](https://codeclimate.com/github/elcuervo/minuteman)

[![Build Status](https://travis-ci.org/elcuervo/minuteman.svg)](https://travis-ci.org/elcuervo/minuteman)

> Minutemen were members of teams from Massachusetts that were well-prepared
militia companies of select men from the American colonial partisan militia
during the American Revolutionary War. _They provided a highly mobile, rapidly
deployed force that allowed the colonies to respond immediately to war threats,
hence the name._

## Installation

```bash
gem install minuteman
```

### Configuration

Configuration exists within the `config` block:

```ruby
Minuteman.configure do |config|
  # You need to use Redic to define a new Redis connection
  config.redis = Redic.new("redis://127.0.0.1:6379/1")

  # The prefix affects operations
  config.prefix = "Tomato"

  # The patterns is what Minuteman uses for the tracking/counting and the
  # different analyzers
  config.patterns = {
    dia: -> (time) { time.strftime("%Y-%m-%d") }
  }
end
```

## Tracking

Tracking is the most basic scenario for Minuteman:

```ruby
# This will create the "landing:new" event in all the defined patterns and since
# there is no user here it will create an annonymous one.
# This user only exists in the Minuteman context.
user = Minuteman.track("landing:new")

# The id it's an internal representation, not useful for you
user.id  # => "1"

# This is the unique id. With this you can have an identifier for the user
user.uid # => "787c8770-0ac2-4654-9fa4-e57d152fa341"

# You can use the `user` to keep tracking things:
user.track("register:page")

# Or use it as an argument
Minuteman.track("help:page", user)

# Or track several users at once
Minuteman.track("help:page", [user1, user2, user3])

# By default all the tracking and counting events are triggered with `Time.now.utc`
# but you can change that as well:
Minuteman.track("setup:account", user, Time.new(2010, 2, 10))
```

## Analysis

There is a powerful engine behind all the operations which is Redis + Lua <3

```ruby
# The analysis of information relies on `Minuteman.patterns` and if you don't
# change it you'll get acess to `year`, `month`, `day`, `hour`, `minute`.
# To get information about `register:page` for today:
Minuteman.analyze("register:page").day

# You can always pass a `Time` instance to set the time you need information.
Minuteman.analyze("register:page").day(Time.new(2004, 2, 12))

# You also have a shorthand for analysis:
register_page_month = Minuteman("register:page").month

# And the power of Minuteman relies on the operations you can do with that.
# Counting the amount:
register_page_month.count # => 10

# Or knowing if a user is included in that set:
register_page_month.include?(User[42]) # => true

# But the most important part is the ability to do bit operations on that:
# You can intersect sets using bitwise AND(`&`), OR(`|`), NOT(`~`, `-`) and XOR(`^`).
# Also you can use plus(`+`) and minus(`-`) operations.
# In this example we'll get all the users that accessed our site via a promo
# invite but didn't buy anything
(
  Minuteman("promo:email").day & Minuteman("promo:google").day
) - Minuteman("buy:success").day
```

## Counting

Since Minuteman 2.0 there's the possibility to have counters.

```ruby
# Counting works in a very similar way to tracking but with some important
# differences. Trackings are idempotent unlike countings and they do not provide
# operations between sets... you can use plain ruby for that.
# This will add 1 to the `hits:page` counter:
Minuteman.add("hits:page")

# You can also pass a `Time` instance to define when this tracking ocurred:
Minuteman.add("hits:page", Time.new(2012, 20, 01))

# And you can also send users to also count the times that given user did that
# event
Minuteman.add("hits:page", Time.new(2012, 20, 01), user)

# You can access counting information similar to tracking:
Minuteman.count("hits:page").day.count # => 201

# Or with a shorthand:
Counterman("hits:page").day.count # => 201
```

## Users

Minuteman 2.0 adds the concept of users which can be annonymous or have a
relation with your own database.

```ruby
# This will create an annonymous user
user = Minuteman::User.create

# Users are just a part of Minuteman and do not interfere with your own.
# They do have some properties like a unique identifier you can use to find it
# in the future
user.uid # => "787c8770-0ac2-4654-9fa4-e57d152fa341"

# User lookup works like this:
# And you can use that unique identifier as a key in a cookie to see what your
# users do when no one is looking
Minuteman::User['787c8770-0ac2-4654-9fa4-e57d152fa341']

# But since the point is to be able to get tied to your data you can promote a
# user, from anonymous to "real"
user.promote(123)

# Lookups also work with promoted ids
Minuteman::User["123"]

# Having a user you can do all the same operations minus the hussle.
# Like tracking:
user.track("user:login")

# or adding:
user.add("failed:login")

# or counting
user.count("failed:login").month.count # => 23

# But also the counted events go to the big picture
Counterman("failed:login").month.count # => 512
```
