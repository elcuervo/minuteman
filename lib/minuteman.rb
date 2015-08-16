require 'redic'
require 'minuteman/user'
require 'minuteman/analyzer'

module Minuteman
  LUA_CACHE      = Hash.new { |h, k| h[k] = Hash.new }
  LUA_OPERATIOSN = File.expand_path("../lua/operations.lua",   __FILE__)

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

    # Stolen
    def script(file, *args)
      begin
        cache = LUA_CACHE[redis.url]

        if cache.key?(file)
          sha = cache[file]
        else
          src = File.read(file)
          sha = redis.call("SCRIPT", "LOAD", src)

          cache[file] = sha
        end

        redis.call!("EVALSHA", sha, *args)

      rescue RuntimeError
        case $!.message
        when ErrorPatterns::NOSCRIPT
          LUA_CACHE[redis.url].clear
          retry
        when ErrorPatterns::DUPLICATE
          raise UniqueIndexViolation, $1
        else
          raise $!
        end
      end
    end

    def analyzers_cache
      @_analyzers_cache ||= Hash.new { |h,k| h[k] = Minuteman::Analyzer.new(k) }
    end
  end
end

def Minuteman(action)
  Minuteman.analyze(action)
end
