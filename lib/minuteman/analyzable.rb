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
      Minuteman.config.redis.call("BITCOUNT", key)
    end

    def include?(user)
      Minuteman.config.redis.call("GETBIT", key, user.id) == 1
    end

    private

    def key_exists?(key)
      Minuteman.config.redis.call("EXISTS", key) == 1
    end

    def operation(action, events = [])
      base_key = Minuteman.config.operations_prefix

      destination_key = if action == "NOT"
                          "#{base_key}#{events[0].id}:#{action}"
                        else
                          src, dst = events[0].id, events[1].id
                          "#{base_key}#{src}:#{action}:#{dst}"
                        end

      if key_exists?(destination_key)
        return Minuteman::Result.new(destination_key)
      end

      script(Minuteman::LUA_OPERATIONS, 0, action.upcase.to_json,
             events.map(&:key).to_json, destination_key.to_json)

      Minuteman::Result.new(destination_key)
    end

    # Code taken from Ohm. Just small changes to adapt to the current Minuteman
    # stuff. elcuervo <3 (soveran + djanowski)
    def script(file, *args)
      begin
        cache = Minuteman::LUA_CACHE[Minuteman.config.redis.url]

        if cache.key?(file)
          sha = cache[file]
        else
          src = File.read(file)
          sha = Minuteman.config.redis.call("SCRIPT", "LOAD", src)

          cache[file] = sha
        end

        Minuteman.config.redis.call!("EVALSHA", sha, *args)

      rescue RuntimeError
        case $!.message
        when ErrorPatterns::NOSCRIPT
          Minuteman::LUA_CACHE[Minuteman.config.redis.url].clear
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
