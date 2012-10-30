class Minuteman
  module BitOperations
    BIT_OPERATION_PREFIX = "bitop"

    def include?(id)
      redis.getbit(key, id) == 1
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

    def bit_operation(type, events)
      destination_key = [
        Minuteman::PREFIX,
        BIT_OPERATION_PREFIX,
        type,
        events.join("-")
      ].join("_")

      @redis.bitop(type, destination_key, events)
      BitOperation.new(@redis, destination_key)
    end
  end

  class BitOperation < Struct.new(:redis, :key)
    include BitOperations
  end
end
