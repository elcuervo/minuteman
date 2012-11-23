require_relative "../test_helper"
require "minitest/benchmark"

describe Minuteman do
  before do
    ENV.delete("NOCACHE")

    today     = Time.now.utc
    last_week = today - (3600 * 24 * 7)

    @analytics = Minuteman.new
    @analytics.mark("login", 12)
    @analytics.mark("login", [2, 42])
    @analytics.mark("login:successful", 567, last_week)

    @week_events       = @analytics.week("login")
    @last_week_events  = @analytics.week("login", last_week)
    @last_week_events2 = @analytics.month("login:successful", last_week)
  end

  bench_performance_constant("AND")   { @week_events & @last_week_events }
  bench_performance_constant("OR")    { @week_events | @last_week_events }
  bench_performance_constant("XOR")   { @week_events ^ @last_week_events }
  bench_performance_constant("NOT")   { ~@week_events }
  bench_performance_constant("MINUS") { @week_events - @last_week_events }

  bench_performance_constant "complex operations" do
    @week_events & (@last_week_events ^ @last_week_events2)
  end

  bench_performance_constant "intersections using cache" do
    5.times { @week_events & [2, 12, 43] }
  end

  bench_performance_constant "intersections not using cache" do
    ENV["NOCACHE"] = "true"
    5.times { @week_events & [2, 12, 43] }
  end
end
