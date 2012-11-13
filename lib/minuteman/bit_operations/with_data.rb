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
        normalized_data = Array(data)
        key = destination_key("data-#{type}", normalized_data)
        command = case type
                  when "AND"    then :select
                  when "MINUS"  then :reject
                  end

        intersected_data = normalized_data.send(command) do |id|
          redis.getbit(source_key, id) == 1
        end

        intersected_data.each { |id| redis.setbit(key, id, 1) }
        Data.new(redis, key, intersected_data)
      end
    end
  end
end
