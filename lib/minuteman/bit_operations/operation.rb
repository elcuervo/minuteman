require "minuteman/bit_operations/plain"
require "minuteman/bit_operations/with_data"

class Minuteman
  module BitOperations
    # Public: Handles the operations between two timespans
    #
    #   redis:      The Redis connection
    #   type:       The operation type
    #   timespan:   One of the timespans to be permuted
    #   other:      The other timespan to be permuted
    #
    class Operation < Struct.new(:redis, :type, :timespan, :other)
      def call
        if type == "MINUS" && operable?
          return timespan ^ (timespan & other)
        end

        klass.new(redis, type, other, timespan.key).call
      end

      private

      # Private: returns the class to use for the operation
      #
      #   timespan: The given timespan
      #
      def klass
        case true
        when other.is_a?(Array) then WithData
        when other.is_a?(String), operable? then Plain
        end
      end

      # Private: Checks if a timespan is operable
      #
      #   timespan: The given timespan
      #
      def operable?
        other.class.ancestors.include?(BitOperations)
      end
    end
  end
end
