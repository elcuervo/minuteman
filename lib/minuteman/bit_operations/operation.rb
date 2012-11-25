require "minuteman/bit_operations/plain"
require "minuteman/bit_operations/with_data"

# Public: Minuteman core classs
#
class Minuteman
  module BitOperations
    # Public: Handles the operations between two timespans
    #
    #   redis:      The Redis connection
    #   type:       The operation type
    #   timespan:   One of the timespans to be permuted
    #   other:      The other timespan to be permuted
    #
    class Operation < Struct.new(:redis, :timespan)
      # Public: Caches operations against Array
      #
      class Cache
        attr_reader :cache

        def initialize
          @cache = {}
        end

        # Public: Access a cached object
        #
        #   array: The original data set
        #
        def [](array)
          cache.fetch(array.sort.hash)
        end

        # Public: Caches an object
        #
        #   array:  The original data set
        #   object: The object to be cached
        #
        def []=(array, object)
          cache[array.sort.hash] = object
        end

        # Public: Checks for the existance of an array in the cache
        #
        #   array:  The original data set
        #
        def include?(array)
          cache.keys.include?(array.sort.hash) if array.is_a?(Array)
        end
      end

      attr_reader   :other
      attr_accessor :cache

      # Public: Initializes the Operation and starts the cache
      #
      def initialize(*)
        super

        @cache = Cache.new
      end

      # Public: Executes an operation
      #
      #   type: The string type of the operation
      #   other: The other set to be operated, can be Array or BitOperations
      #
      def call(type, other)
        @other = other

        return minus_operation  if type == "MINUS" && operable?
        return cache[other]     if cache.include?(other)

        caching { klass.new(redis, type, other, timespan.key).call }
      end

      private

      # Private: Executes a minus operation between the sets
      #
      def minus_operation
        timespan ^ (timespan & other)
      end

      # Private: Caches any caching capable operation
      #
      def caching
        executed_class = yield
        cache[other] = executed_class if other.is_a?(Array) && !ENV["NOCACHE"]
        executed_class
      end

      # Private: returns the class to use for the operation
      #
      #   timespan: The given timespan
      #
      def klass
        case true
        when other.is_a?(String), operable? then Plain
        when other.is_a?(Array) then WithData
        else raise(TypeError, "Unsupported type")
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
