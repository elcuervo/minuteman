require "minuteman/bit_operations/operation"

# Public: Minuteman core classs
#
class Minuteman
  module BitOperations
    extend Forwardable

    def_delegators :Minuteman, :safe, :redis

    # Public: Checks for the existance of ids on a given set
    #
    #   ids - Array of ids
    #
    def include?(*ids)
      result = ids.map { |id| getbit(id) }
      result.size == 1 ? result.first : result
    end

    # Public: Resets the current key
    #
    def reset
      safe { redis.rem(key) }
    end

    # Public: Cheks for the amount of ids stored on the current key
    #
    def length
      safe { redis.bitcount(key) }
    end

    # Public: Calculates the NOT of the current key
    #
    def -@
      operation("NOT", key)
    end
    alias :~@ :-@

    # Public: Calculates the substract of one set to another
    #
    #   timespan: Another BitOperations enabled class
    #
    def -(timespan)
      operation("MINUS", timespan)
    end

    # Public: Calculates the XOR against another timespan
    #
    #   timespan: Another BitOperations enabled class
    #
    def ^(timespan)
      operation("XOR", timespan)
    end

    # Public: Calculates the OR against another timespan
    #
    #   timespan: Another BitOperations enabled class or an Array
    #
    def |(timespan)
      operation("OR", timespan)
    end
    alias :+ :|

    # Public: Calculates the AND against another timespan
    #
    #   timespan: Another BitOperations enabled class or an Array
    #
    def &(timespan)
      operation("AND", timespan)
    end

    private

    # Private: Helper to access the value a given bit
    #
    #   id: The bit
    #
    def getbit(id)
      safe { redis.getbit(key, id) == 1 }
    end

    # Private: Cxecutes an operation between the current timespan and another
    #
    #   type:     The operation type
    #   timespan: The given timespan
    #
    def operation(type, timespan)
      operate.call(type, timespan)
    end

    # Private: Memoizes the operation class
    #
    def operate
      @_operate ||= Operation.new(self)
    end
  end
end
