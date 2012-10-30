class BitAnalytics
  class TimeSpan
    attr_reader :key, :redis

    DATE_FORMAT = "%s-%02d-%02d"
    TIME_FORMAT = "%02d:%02d"

    def initialize(redis, event_name, date)
      @redis = redis
      @key = build_key(event_name, time_format(date))
    end

    def include?(id)
      redis.getbit(key, id) == 1
    end

    def length
      redis.bitcount(key)
    end

    def build_key(event_name, date)
      [BitAnalytics::PREFIX, event_name, date.join("-")].join("_")
    end
  end
end
