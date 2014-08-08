require 'redic'
require 'ook'
require 'minuteman/user'

module Minuteman
  class << self
    def redis
      @_redis ||= Ohm.redis
    end

    def redis=(redis)
      @_redis = redis

      Ohm.redis = @_redis
    end

    def track(action, users, time = Time.now.utc)
      Array(users).each do |user|
        Minuteman.redis.call("SETBIT", action, user.id, 1)
      end
    end

    def minute(action)
    end
  end
end
