require "minuteman/bit_operations"

class Minuteman
  # Public: The result of intersecting results
  #
  #   redis   - The Redis connection
  #   key     - The key where the result it's stored
  #
  class BitOperationResult < Struct.new(:redis, :key)
    include BitOperations
  end
end
