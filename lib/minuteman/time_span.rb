require "minuteman/bit_operations"

# Public: Minuteman core classs
#
class Minuteman
  # Public: The timespan class. All the time span classes inherit from this one
  #
  class TimeSpan
    include BitOperations

    attr_reader :key, :redis

    DATE_FORMAT = "%s-%02d-%02d"
    TIME_FORMAT = "%02d:%02d"

    # Public: Initializes the base TimeSpan class
    #
    #   redis      - The Redis connection
    #   event_name - The event to be tracked
    #   date       - A given Time object
    #
    def initialize(redis, event_name, date)
      @redis = redis
      @key = build_key(event_name, time_format(date))
    end

    private

    # Private: The redis key that's going to be used
    #
    #   event_name - The event to be tracked
    #   date       - A given Time object
    #
    def build_key(event_name, date)
      [Minuteman::PREFIX, event_name, date.join("-")].join("_")
    end
  end
end
