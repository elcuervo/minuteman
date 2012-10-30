require "redis"
require "time"
require "bitanalytics/time_events"

class BitAnalytics
  attr_reader :redis

  PREFIX = "bitanalytics"

  # Public:
  #
  def initialize(options = {})
    @redis = Redis.new(options)
  end

  %w[month week days hour].each do |method_name|
    define_method(method_name) do |event_name, date|
      constructor = self.class.const_get(method_name.capitalize)
      constructor.new(@redis, event_name, date)
    end
  end

  # Public
  #
  def mark(event_name, id, time = Time.now.utc)
    event_time = time.kind_of?(Time) ? time : Time.parse(time.to_s)
    time_events = TimeEvents.start(redis, event_name, event_time)

    @redis.multi do
      time_events.each { |event| redis.setbit(event.key, id, 1) }
    end
  end

  def reset_all
    keys = @redis.keys([PREFIX, "*"].join("_"))
    @redis.del(keys) if keys.any?
  end
end
