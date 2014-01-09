
analytics = Minuteman.new
analytics.track("event", 1) # => user.id
user = analytics.track("event") # => Minuteman::User
user.internal_id! 1 # => Sets the internal id to a given thing
