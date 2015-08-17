require "msgpack"

module Minuteman
  module Analyzable
    module ErrorPatterns
      DUPLICATE = /(UniqueIndexViolation: (\w+))/.freeze
      NOSCRIPT = /^NOSCRIPT/.freeze
    end

    def |(time_span)
      operation("AND", [ key, time_span.key ] )
    end
    alias_method :+, :|

    private

    def operation(action, keys = [])
      script(Minuteman::LUA_OPERATIONS,
             Minuteman.prefix,
             action.upcase,
             keys.to_msgpack)
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
          raise $!
        end
      end
    end

  end
end
