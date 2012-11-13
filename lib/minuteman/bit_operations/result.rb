require "minuteman/bit_operations"

class Minuteman
  module BitOperations
    # Public: The result of intersecting results
    #
    #   redis   - The Redis connection
    #   key     - The key where the result it's stored
    #
    class Result < Struct.new(:redis, :key)
      include BitOperations
    end
  end
end
