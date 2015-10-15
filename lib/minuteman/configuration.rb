module Minuteman
  class Configuration
    attr_accessor :redis
    attr_accessor :patterns
    attr_accessor :prefix

    def initialize
      @redis = Ohm.redis
      @prefix = "Minuteman::"
      @patterns = {
        year:   -> (time) { time.strftime("%Y") },
        month:  -> (time) { time.strftime("%Y-%m") },
        day:    -> (time) { time.strftime("%Y-%m-%d") },
        hour:   -> (time) { time.strftime("%Y-%m-%d %H") },
        minute: -> (time) { time.strftime("%Y-%m-%d %H:%m") },
      }
    end

    def redis=(redis)
      @redis = redis
      Ohm.redis = redis
    end
  end
end
