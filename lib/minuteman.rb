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

# Public: Minuteman core classs
#
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
    define_method(method_name) do |*args|
      event_name, date = *args
      date ||= Time.now.utc

      constructor = self.class.const_get(method_name.capitalize)
      constructor.new(redis, event_name, date)
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

    mark_events(time_events, Array(ids))
  end

  # Public: List all the events given the minuteman namespace
  #
  def events
    keys = redis.keys([PREFIX, "*", "????"].join("_"))
    keys.map { |key| key.split("_")[1] }
  end

  # Public: List all the operations executed in a given the minuteman namespace
  #
  def operations
    redis.keys([operations_cache_key_prefix, "*"].join("_"))
  end

  # Public: Resets the bit operation cache keys
  #
  def reset_operations_cache
    keys = redis.keys([operations_cache_key_prefix, "*"].join("_"))
    redis.del(keys) if keys.any?
  end

  # Public: Resets all the used keys
  #
  def reset_all
    keys = redis.keys([PREFIX, "*"].join("_"))
    redis.del(keys) if keys.any?
  end

  private

  # Private: Marks ids for a given time events
  #
  #  time_events: A set of TimeEvents
  #  ids:         The ids to be marked
  #
  def mark_events(time_events, ids)
    redis.multi do
      time_events.each do |event|
        ids.each { |id| redis.setbit(event.key, id, 1) }
      end
    end
  end

  # Private: The prefix key of all the operations
  #
  def operations_cache_key_prefix
    [
      PREFIX, Minuteman::KeysMethods::BIT_OPERATION_PREFIX
    ].join("_")
  end
end
