require 'minuteman'
require 'benchmark'

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

Benchmark.bmbm(7) do |x|
  x.report("tracking users") {
    Minuteman.track("first:page", users_three)
  }

  x.report("tracking annoymous users") {
    1000.times { Minuteman.track("first:page") }
  }

  x.report("operation: AND") {
    1000.times { Minuteman("first:page").day & Minuteman("second:page").day }
  }

  x.report("operation: OR") {
    1000.times { Minuteman("first:page").day | Minuteman("second:page").day }
  }

  x.report("operation: XOR") {
    1000.times { Minuteman("first:page").day ^ Minuteman("second:page").day }
  }

  x.report("operation: NOT") {
    1000.times { -Minuteman("second:page").day }
  }

  x.report("operation: MINUS") {
    1000.times { Minuteman("first:page").day + Minuteman("second:page").day }
  }

  x.report("complex operations") {
    1000.times {
      (
        Minuteman("first:page").day + Minuteman("second:page").day
      ) - Minuteman("third:page").day
    }
  }

  x.report("adding to the counter") {
    1000.times {
      Minuteman.add("first:counter")
    }
  }
end
