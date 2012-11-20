---
layout: main
---

## What kind of sorcery is this?!

## Why Minuteman it's called that way?

_Wikipedia_: Minutemen were members of teams from Massachusetts that were
well-prepared
militia companies of select men from the American colonial partisan militia
during the American Revolutionary War. _They provided a highly mobile, rapidly
deployed force that allowed the colonies to respond immediately to war threats,
hence the name._

## How do I use it?

```bash
  gem install minuteman
```

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

