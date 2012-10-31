class Minuteman
  module BitOperations
    BIT_OPERATION_PREFIX = "bitop"

    def include?(*ids)
      result = ids.map { |id| redis.getbit(key, id) == 1 }
      result.size == 1 ? result.first : result
    end

    def reset
      redis.rem(key)
    end

    def length
      redis.bitcount(key)
    end

    def ^(timespan)
      bit_operation("XOR", [key, timespan.key])
    end

    def |(timespan)
      bit_operation("OR", [key, timespan.key])
    end

    def &(timespan)
      bit_operation("AND", [key, timespan.key])
    end

    private

    def destination_key(type, events)
      [
        Minuteman::PREFIX,
        BIT_OPERATION_PREFIX,
        type,
        events.join("-")
      ].join("_")
    end

    def bit_operation(type, events)
      key = destination_key(type, events)
      @redis.bitop(type, key, events)
      BitOperation.new(@redis, key)
    end
  end

  class BitOperation < Struct.new(:redis, :key)
    include BitOperations
  end
end
