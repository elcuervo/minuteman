require 'msgpack'

module Minuteman
  module Analyzable
    module ErrorPatterns
      DUPLICATE = /(UniqueIndexViolation: (\w+))/.freeze
      NOSCRIPT = /^NOSCRIPT/.freeze
    end

    def &(event)
      operation("AND", [self, event])
    end

    def |(event)
      operation("OR", [self, event])
    end
    alias_method :+, :|

    def ^(event)
      operation("XOR", [self, event])
    end

    def -@()
      operation("NOT", [self])
    end
    alias :~@ :-@

    def -(event)
      operation("MINUS", [self, event])
    end

    def count
      Minuteman.redis.call("BITCOUNT", key)
    end

    def include?(user)
      Minuteman.redis.call("GETBIT", key, user.id) == 1
    end

    private

    def operation(action, events = [])
      base_key = "#{Minuteman.prefix}Operation:"

      destination_key = if action == "NOT"
                          "#{base_key}#{events[0].id}:#{action}"
                        else
                          src, dst = events[0].id, events[1].id
                          "#{base_key}#{src}:#{action}:#{dst}"
                        end

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
