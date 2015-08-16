require 'redic'
require 'minuteman/user'
require 'minuteman/analyzer'

module Minuteman
  class << self
    def redis
      @_redis ||= Ohm.redis
    end

    def redis=(redis)
      @_redis = redis

      Ohm.redis = @_redis
    end

    def track(action, users = nil, time = Time.now.utc)
      users = Minuteman::User.create if users.nil?

      Array(users).each do |user|
        Minuteman.redis.call("SETBIT", action, user.id, 1)
      end

      users
    end

    def analyze(action)
      analyzers_cache[action]
    end

    private

    def analyzers_cache
      @_analyzers_cache ||= Hash.new { |h,k| h[k] = Minuteman::Analyzer.new(k) }
    end
  end
end
