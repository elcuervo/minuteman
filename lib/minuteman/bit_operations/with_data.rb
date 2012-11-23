require "minuteman/keys_methods"
require "minuteman/bit_operations/data"

class Minuteman
  module BitOperations
    # Public: The class to handle operations with datasets
    #
    #   redis:      The Redis connection
    #   type:       The operation type
    #   data:       The data to be permuted
    #   source_key: The original key to do the operation
    #
    class WithData < Struct.new(:redis, :type, :data, :source_key)
      include KeysMethods

      def call
        key = destination_key("data-#{type}", normalized_data)

        if !redis.exists(key)
          intersected_data.each { |id| redis.setbit(key, id, 1) }
        end

        Data.new(redis, key, intersected_data)
      end

      private

      # Private: Normalized data
      #
      def normalized_data
        Array(data)
      end

      # Private: Defines command to get executed based on the type
      #
      def command
        case type
        when "AND"    then :select
        when "MINUS"  then :reject
        end
      end

      # Private: The intersected data depending on the command executed
      #
      def intersected_data
        normalized_data.send(command) { |id| redis.getbit(source_key, id) == 1 }
      end
    end
  end
end
