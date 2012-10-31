class Minuteman
  module BitOperations
    BIT_OPERATION_PREFIX = "bitop"

    # Public: Checks for the existance of ids on a given set
    #
    #   ids - Array of ids
    #
    def include?(*ids)
      result = ids.map { |id| redis.getbit(key, id) == 1 }
      result.size == 1 ? result.first : result
    end

    # Public: Resets the current key
    #
    def reset
      redis.rem(key)
    end

    # Public: Cheks for the amount of ids stored on the current key
    #
    def length
      redis.bitcount(key)
    end

    # Public: Calculates the NOT of the current key
    #
    def -@
      bit_operation("NOT", key)
    end

    # Public: Calculates the XOR against another timespan
    #
    #   timespan: Another BitOperations enabled class
    #
    def ^(timespan)
      bit_operation("XOR", [key, timespan.key])
    end

    # Public: Calculates the OR against another timespan
    #
    #   timespan: Another BitOperations enabled class
    #
    def |(timespan)
      bit_operation("OR", [key, timespan.key])
    end

    # Public: Calculates the AND against another timespan
    #
    #   timespan: Another BitOperations enabled class
    #
    def &(timespan)
      bit_operation("AND", [key, timespan.key])
    end

    private

    # Private: The destination key for the operation
    #
    #   type   - The bitwise operation
    #   events - The events to permuted
    #
    def destination_key(type, events)
      [
        Minuteman::PREFIX,
        BIT_OPERATION_PREFIX,
        type,
        events.join("-")
      ].join("_")
    end

    # Private: Executes a bit operation
    #
    #   type   - The bitwise operation
    #   events - The events to permuted
    #
    def bit_operation(type, events)
      key = destination_key(type, Array(events))
      @redis.bitop(type, key, events)
      BitOperation.new(@redis, key)
    end
  end

  class BitOperation < Struct.new(:redis, :key)
    include BitOperations
  end
end
