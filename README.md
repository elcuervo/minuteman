# Minuteman
[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/elcuervo/minuteman)

_Wikipedia_: Minutemen were members of teams from Massachusetts that were well-prepared
militia companies of select men from the American colonial partisan militia
during the American Revolutionary War. _They provided a highly mobile, rapidly
deployed force that allowed the colonies to respond immediately to war threats,
hence the name._

![Minuteman](http://upload.wikimedia.org/wikipedia/commons/thumb/4/4b/Minute_Man_Statue_Lexington_Massachusetts_cropped.jpg/220px-Minute_Man_Statue_Lexington_Massachusetts_cropped.jpg)

Fast analytics using Redis bitwise operations

## Origin
Freenode - #cuba.rb - 2012/10/30 15:20 UYT

**conanbatt:** anyone here knows some good web app metrics tool ?

**conanbatt:** i use google analytics for the page itself, and its good, but for the webapp its really not useful

**tizoc: conanbatt:** http://amix.dk/blog/post/19714 you can port this (if an equivalent doesn't exist already)

**conanbatt:** the metrics link is excellent but its python and released 5 days ago lol

**elcuervo: tizoc:** the idea it's awesome

**elcuervo:** interesting...


## Inspiration

* http://blog.getspool.com/2011/11/29/fast-easy-realtime-metrics-using-redis-bitmaps/
* http://amix.dk/blog/post/19714
* http://en.wikipedia.org/wiki/Bit_array

## Installation

### Important!

Depends on Redis 2.6 for the `bitop` operation. You can install it using:

```bash
brew install --devel redis
```

or upgrading your current version:

```bash
brew upgrade --devel redis
```

And then install the gem

```bash
gem install minuteman
```

## Usage

```ruby
require "minuteman"

# Accepts an options hash that will be sent as is to Redis.new
analytics = Minuteman.new

# Mark an event for a given id
analytics.mark("login:successful", user.id)
analytics.mark("login:successful", other_user.id)

# Mark in bulk
analytics.mark("programming:love:ruby", User.where(favorite: "ruby").pluck(:id))

# Fetch events for a given time
today_events = analytics.day("login:successful", Time.now.utc)

# This also exists
analytics.year("login:successful", Time.now.utc)
analytics.month("login:successful", Time.now.utc)
analytics.week("login:successful", Time.now.utc)
analytics.day("login:successful", Time.now.utc)
analytics.hour("login:successful", Time.now.utc)
analytics.minute("login:successful", Time.now.utc)

# Lists all the tracked events
analytics.events
#=> ["login:successful", "programming:login:ruby"]

# Check event length on a given time
today_events.length
#=> 2

# Check for existance
today_events.include?(user.id)
#=> true
today_events.include?(admin.id)
#=> false

# Bulk check
today_events.include?(User.all.pluck(:id))
#=> [true, true, false, false]
```

## Bitwise operations

You can intersect sets using bitwise AND(`&`), OR(`|`), NOT(`~`, `-`) and XOR(`^`).
Also you can use plus(`+`) and minus(`-`) operations.

```ruby
set1 + set2
set1 - set2
set1 & set2
set1 | set2
set1 ^ set2

~set1 \
       |==> This are the same
-set1 /
```

### Intersecting with arrays

Let's assume this scenario:

You have a list of users and want to know which of them have been going throught
some of the marks you made.

```ruby
paid = analytics.month("buy:complete")
payed_from_miami = paid & User.find_all_by_state("MIA").map(&:id)
payed_from_miami.size
#=> 43
payed_users_from_miami = payed_from_miami.map { |id| User.find(id) }
```

Currently the supported commands to interact with arrays are `&` and `-`

### Example

```ruby
invited = analytics.month("email:invitation", Time.now.utc)
successful_buys = analytics.month("buy:complete", Time.now.utc)

successful_buys_after_invitation = invited & successful_buys
successful_buys_after_invitation.include?(user.id)

# Clean up all the operations cache
analytics.reset_operations_cache
```

Also you can write more complex set operations

```ruby
invited = analytics.month("email:invitation")
from_adsense = analytics.month("adsense:promo")
successful_buys = analytics.month("buy:complete")

conversion_rate = (invited | from_adsense) & successful_buys
```
