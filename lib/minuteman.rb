require "redis"
require "time"
require "minuteman/time_events"

# Until redis gem gets updated
class Redis
  def bitop(operation, destkey, *keys)
    synchronize do |client|
      client.call([:bitop, operation, destkey] + keys)
    end
  end

  def bitcount(key, start = 0, stop = -1)
    synchronize do |client|
      client.call([:bitcount, key, start, stop])
    end
  end
end

class Minuteman
  attr_reader :redis

  PREFIX = "minuteman"

  # Public: Initializes Minuteman
  #
  # options - The hash to be sent to Redis.new
  #
  def initialize(options = {})
    @redis = Redis.new(options)
  end

  # Public: Generates the methods to fech data
  #
  #   event_name - The event name to be searched for
  #   date       - A Time object used to do the search
  #
  %w[year month week day hour minute].each do |method_name|
    define_method(method_name) do |event_name, date|
      constructor = self.class.const_get(method_name.capitalize)
      constructor.new(@redis, event_name, date)
    end
  end

  # Public: Marks an id to a given event on a given time
  #
  #   event_name - The event name to be searched for
  #   ids        - The ids to be tracked
  #
  # Examples
  #
  #   analytics = Minuteman.new
  #   analytics.mark("login", 1)
  #   analytics.mark("login", [2, 3, 4])
  #
  def mark(event_name, ids, time = Time.now.utc)
    event_time = time.kind_of?(Time) ? time : Time.parse(time.to_s)
    time_events = TimeEvents.start(redis, event_name, event_time)

    @redis.multi do
      time_events.each do |event|
        Array(ids).each { |id| redis.setbit(event.key, id, 1) }
      end
    end
  end

  # Public: Resets the bit operation cache keys
  #
  def reset_operations_cache
    prefix = [
      PREFIX, Minuteman::BitOperations::BIT_OPERATION_PREFIX
    ].join("_")

    keys = @redis.keys([prefix, "*"].join("_"))
    @redis.del(keys) if keys.any?
  end

  # Public: Resets all the used keys
  #
  def reset_all
    keys = @redis.keys([PREFIX, "*"].join("_"))
    @redis.del(keys) if keys.any?
  end
end
