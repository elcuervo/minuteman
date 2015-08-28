require "msgpack"

module Minuteman
  module Analyzable
    module ErrorPatterns
      DUPLICATE = /(UniqueIndexViolation: (\w+))/.freeze
      NOSCRIPT = /^NOSCRIPT/.freeze
    end

    def |(time_span)
      operation("AND", [id, time_span.id])
    end
    alias_method :+, :|

    private

    def operation(action, keys = [])
      script(Minuteman::LUA_OPERATIONS,
             0, Minuteman.prefix.to_msgpack,
             action.upcase.to_msgpack,
             keys.to_msgpack)
      Minuteman::TimeSpan
    end

    # Stolen
    def script(file, *args)
      begin
        cache = Minuteman::LUA_CACHE[Minuteman.redis.url]

        if cache.key?(file)
          sha = cache[file]
        else
          src = File.read(file)
          sha = Minuteman.redis.call("SCRIPT", "LOAD", src)

          cache[file] = sha
        end

        Minuteman.redis.call!("EVALSHA", sha, *args)

      rescue RuntimeError
        case $!.message
        when ErrorPatterns::NOSCRIPT
          Minuteman::LUA_CACHE[Minuteman.redis.url].clear
          retry
        when ErrorPatterns::DUPLICATE
          raise UniqueIndexViolation, $1
        else
          require 'byebug'
          byebug
          raise $!
        end
      end
    end

  end
end
