require "minuteman/keys_methods"
require "minuteman/bit_operations/result"

class Minuteman
  module BitOperations
    # Public: The class to handle operations with others timespans
    #
    #   redis:      The Redis connection
    #   type:       The operation type
    #   timespan:   The timespan to be permuted
    #   source_key: The original key to do the operation
    #
    class Plain < Struct.new(:redis, :type, :timespan, :source_key)
      include KeysMethods

      def call
        events = if source_key == timespan
                   Array(source_key)
                 else
                   [source_key, timespan.key]
                 end

        key = destination_key(type, events)
        redis.bitop(type, key, events)

        Result.new(redis, key)
      end
    end
  end
end
