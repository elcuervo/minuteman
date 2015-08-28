require 'msgpack'

module Minuteman
  module Analyzable
    module ErrorPatterns
      DUPLICATE = /(UniqueIndexViolation: (\w+))/.freeze
      NOSCRIPT = /^NOSCRIPT/.freeze
    end

    def |(event)
      operation("AND", [self, event])
    end
    alias_method :+, :|

    def count
      Minuteman.redis.call("BITCOUNT", key)
    end

    private

    def operation(action, events = [])
      destination_key = "#{Minuteman.prefix}Operation:#{events[0].id}:#{action}:#{events[1].id}"

      result_key = script(Minuteman::LUA_OPERATIONS,
                          0, action.upcase.to_msgpack,
                          events.map(&:key).to_msgpack,
                          destination_key.to_msgpack
                         )

      Minuteman::Result.new(result_key)
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
