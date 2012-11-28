require "minuteman/bit_operations"

# Public: Minuteman core classs
#
class Minuteman
  module BitOperations
    # Public: The result of intersecting results
    #
    #   key     - The key where the result it's stored
    #
    class Result < Struct.new(:key)
      include BitOperations
    end
  end
end
