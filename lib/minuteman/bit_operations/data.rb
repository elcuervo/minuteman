require "minuteman/bit_operations"

# Public: Minuteman core classs
#
class Minuteman
  module BitOperations
    # Public: The conversion of an array to an operable class
    #
    #   key     - The key where the result it's stored
    #   data    - The original data of the intersection
    #
    class Data < Struct.new(:key, :data)
      include BitOperations
      include Enumerable

      def to_ary
        data
      end

      def size
        data.size
      end

      def each(&block)
        data.each(&block)
      end

      def ==(other)
        other == data
      end
    end
  end
end
