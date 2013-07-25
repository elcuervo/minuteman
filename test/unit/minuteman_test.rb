require_relative "../test_helper"

describe Minuteman do
  Given(:analytics)   { Minuteman.new }

  after { analytics.reset_all }

  context "configuration" do
    Then { analytics.redis }
    Then { analytics.options[:cache] == true }

    context "switching options" do
      Given(:minuteman) { Minuteman.new }

      When { minuteman.options[:cache] = false }
      Then { minuteman.options[:cache] == false }
    end

    context "changing time spans" do
      Given(:time_spans) { %w[year month day hour] }
      Given(:minuteman) { Minuteman.new(time_spans: time_spans) }

      When { minuteman.track("login", 12) }

      Then { minuteman.respond_to?(:year) }
      Then { minuteman.respond_to?(:month) }
      Then { minuteman.respond_to?(:day) }
      Then { minuteman.respond_to?(:hour) }

      Then { !minuteman.respond_to?(:minute) }
      Then { !minuteman.respond_to?(:week) }

      Then { minuteman.redis.keys.size == 4 }
      Then { minuteman.options[:time_spans] == time_spans }
    end

    context "fail silently" do
      Given(:minuteman) { Minuteman.new(silent: true, redis: { port: 1234 }) }
      When(:result) { minuteman.track("test", 1) }
      Then { result == nil }
    end

    context "fail loudly" do
      Given(:minuteman) { Minuteman.new(redis: { port: 1234 }) }
      When(:result) { minuteman.track("test", 1) }
      Then { result == Failure(Redis::CannotConnectError) }
    end

    context "changing Redis connection" do
      Given(:redis) { Redis.new }
      Then { Minuteman.redis != redis }

      context "return the correct connection" do
        When(:minuteman) { Minuteman.new(redis: redis) }

        Then { minuteman.redis == redis }
      end

      context "switching the connection" do
        Given(:minuteman) { Minuteman.new }
        When { minuteman.redis = redis }
        Then { redis == Minuteman.redis }
      end

      context "using Redis::Namespace" do
        Given(:namespace) { Redis::Namespace.new(:ns, redis: Redis.new) }
        Given(:minuteman) { Minuteman.new(redis: namespace) }

        Then { minuteman.redis == namespace }
      end
    end
  end

  context "event tracking" do
    Given(:today)       { Time.now.utc }
    Given(:last_month)  { today - (3600 * 24 * 30) }
    Given(:last_week)   { today - (3600 * 24 * 7) }
    Given(:last_minute) { today - 120 }

    Given(:year_events) { analytics.year("login", today) }
    Given(:week_events) { analytics.week("login", today) }
    Given(:month_events) { analytics.month("login", today) }
    Given(:day_events) { analytics.day("login", today) }
    Given(:hour_events) { analytics.hour("login", today) }
    Given(:minute_events) { analytics.minute("login", today) }
    Given(:last_week_events) { analytics.week("login", last_week) }
    Given(:last_minute_events) { analytics.minute("login", last_minute) }
    Given(:last_month_events) { analytics.month("login:successful", last_month) }

    before do
      analytics.track("login", 12)
      analytics.track("login", [2, 42])
      analytics.track("login", 2, last_week)
      analytics.track("login:successful", 567, last_month)
    end

    Then { analytics.events.size == 2 }
    Then { year_events.length == 3 }
    Then { week_events.length == 3 }
    Then { last_week_events.length == 1 }
    Then { last_month_events.length == 1 }

    context "reseting" do
      before { analytics.reset_all }
      Then { analytics.events.size == 0 }

      context "bit operations" do
        before { week_events & last_week_events }

        When { analytics.reset_operations_cache }
        Then { analytics.operations.size == 0 }
      end
    end

    context "on a given time" do
      Then { year_events.length == 3 }
      Then { week_events.length == 3 }

      Then { week_events.include?(12, 2, 1) == [true, true, false] }
      Then { year_events.include?(12) }
      Then { month_events.include?(12) }
      Then { day_events.include?(12) }
      Then { hour_events.include?(12) }
      Then { minute_events.include?(12) }

      Then { last_week_events.include?(2) }
      Then { !month_events.include?(5) }
      Then { !last_minute_events.include?(12) }
      Then { last_month_events.include?(567) }
    end

    context "listing events" do
      Then { analytics.events.size == 2 }
      Then { analytics.events.sort == ["login", "login:successful"] }
    end

    context "composing" do
      context "using AND" do
        Given(:and_operation) { week_events & last_week_events }

        Then { week_events.include?(2) }
        Then { week_events.include?(12) }

        Then { last_week_events.include?(2) }
        Then { !last_week_events.include?(12) }

        Then { !and_operation.include?(12) }
        Then { and_operation.include?(2) }
        Then { and_operation.length == 1 }
      end

      context "using OR" do
        Given(:or_operation) { week_events | last_week_events }

        Then { week_events.include?(2) }
        Then { last_week_events.include?(2) }
        Then { !last_week_events.include?(12) }

        Then { or_operation.include?(12) }
        Then { or_operation.include?(2) }
        Then { or_operation.length == 3 }
      end

      context "using NOT" do
        Given(:not_operation) { ~week_events }

        Then { week_events.include?(2) }
        Then { week_events.include?(12) }

        Then { !not_operation.include?(12) }
        Then { !not_operation.include?(2) }
      end

      context "using OR alias (+)" do
        Given(:or_operation) { week_events + last_week_events }

        Then { week_events.include?(2) }
        Then { last_week_events.include?(2) }
        Then { !last_week_events.include?(12) }

        Then { or_operation.include?(12) }
        Then { or_operation.include?(2) }
        Then { or_operation.length == 3 }
      end

      context "using MINUS" do
        Given(:substract_operation) { year_events - week_events }

        Then { week_events.include?(2) }
        Then { year_events.include?(2) }
        Then { !substract_operation.include?(2) }
      end
    end

    context "composing multiple operations" do
      Given(:multi_operation) { week_events & last_week_events | year_events }
      Then { multi_operation.is_a?(Minuteman::BitOperations::Result) }
    end

    context "composing against arrays" do
      context "using AND returns the intersection" do
        Given(:ids) { week_events & [2, 12, 43] }

        Then { ids.is_a?(Minuteman::BitOperations::Data) }
        Then { ids == [2, 12] }
      end

      context "using MINUS returns the difference" do
        Given(:ids) { week_events - [2, 12, 43] }

        Then { ids.is_a?(Minuteman::BitOperations::Data) }
        Then { ids == [43] }
      end

      context "returns an object that behaves like Array" do
        Given(:ids) { week_events & [2, 12, 43] }

        Then { ids.each.is_a?(Enumerator) }
        Then { ids.map.is_a?(Enumerator) }
        Then { ids.size == 2 }
      end

    end
  end
end
