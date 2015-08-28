require 'redic'

module Minuteman
  LUA_CACHE      = Hash.new { |h, k| h[k] = Hash.new }
  LUA_OPERATIONS = File.expand_path("../minuteman/lua/operations.lua",   __FILE__)

  class << self
    def redis
      @_redis ||= Ohm.redis
    end

    def redis=(redis)
      @_redis = redis

      Ohm.redis = @_redis
    end

    def prefix
      @_prefix ||= "Minuteman::"
    end

    def patterns
      @_patterns ||= {
        year:   -> (time) { time.strftime("%Y") },
        month:  -> (time) { time.strftime("%Y-%m") },
        day:    -> (time) { time.strftime("%Y-%m-%d") },
        hour:   -> (time) { time.strftime("%Y-%m-%d %H") },
        minute: -> (time) { time.strftime("%Y-%m-%d %H:%m") },
      }
    end

    def time_spans
      @_time_spans ||= patterns.keys
    end

    def track(action, users = nil, time = Time.now.utc)
      users = Minuteman::User.create if users.nil?

      Array(users).each do |user|
        time_spans.each do |time_span|
          key = Minuteman::Event.new(action, patterns[time_span].call(time))
          Minuteman.redis.call("SETBIT", key, user.id, 1)
        end
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

def Minuteman(action)
  Minuteman.analyze(action)
end

require 'minuteman/user'
require 'minuteman/event'
require 'minuteman/analyzer'
