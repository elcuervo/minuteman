require 'minuteman'
require 'benchmark/ips'

Minuteman.configure do |config|
  config.redis = Redic.new("redis://127.0.0.1:6379/1")
  config.parallel = true
end

Minuteman.config.redis.call("FLUSHDB")

users = Array.new(5000) { Minuteman::User.create }
users_one = users.sample(5000)
users_two = users.sample(2000)
users_three = users.sample(1000)

Minuteman.track("first:page", users_one)
Minuteman.track("second:page", users_two)
Minuteman.track("third:page", users_three)

Benchmark.ips do |x|
  x.report("tracking users") { Minuteman.track("first:page", users_three) }

  x.report("tracking annoymous users") {
    Minuteman.track("first:page")
  }

  x.report("operation: AND") {
    Minuteman("first:page").day & Minuteman("second:page").day
  }

  x.report("operation: OR") {
    Minuteman("first:page").day | Minuteman("second:page").day
  }

  x.report("operation: XOR") {
    Minuteman("first:page").day ^ Minuteman("second:page").day
  }

  x.report("operation: NOT") {
    -Minuteman("second:page").day
  }

  x.report("operation: MINUS") {
    Minuteman("first:page").day + Minuteman("second:page").day
  }

  x.report("complex operations") {
    (
      Minuteman("first:page").day + Minuteman("second:page").day
    ) - Minuteman("third:page").day
  }

  x.report("adding to the counter") {
    Minuteman.add("first:counter")
  }

  x.report("checking the counter") {
    Counterman("first:counter").month.count
  }

  x.report("tracking through a user") {
    users.sample.track("some:event")
  }

  x.report("counting through a user") {
    users.sample.add("some:event")
  }

  x.report("checking the counter through a user") {
    users.sample.count("some:event").day.count
  }
end
