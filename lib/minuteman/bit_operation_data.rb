require "minuteman/bit_operations"

class Minuteman
  # Public: The conversion of an array to an operable class
  #
  #   redis   - The Redis connection
  #   key     - The key where the result it's stored
  #   data    - The original data of the intersection
  #
  class BitOperationData < Struct.new(:redis, :key, :data)
    include Minuteman::BitOperations

    def to_ary
      data
    end

    def ==(other)
      other == data
    end
  end
end
