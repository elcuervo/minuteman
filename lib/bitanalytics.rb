require "redis"
require "bitanalytics/time_events"

class BitAnalytics
  attr_reader :redis

  PREFIX = "bitanalytics"

  # Public:
  #
  def initialize(options = {})
    @redis = Redis.new(options)
  end

  # Public
  #
  def mark(event_name, id, time = Time.now.utc)
    time_events = TimeEvents.start(@redis, event_name, time)

    @redis.multi do
      time_events.each do |event|
        @redis.setbit(event.key, id, 1)
      end
    end
  end

  def month_events(event_name, date)
    Month.new(@redis, event_name, date)
  end

end
