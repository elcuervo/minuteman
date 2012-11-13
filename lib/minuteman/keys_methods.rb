class Minuteman
  module KeysMethods
    BIT_OPERATION_PREFIX = "bitop"

    private

    # Private: The destination key for the operation
    #
    #   type   - The bitwise operation
    #   events - The events to permuted
    #
    def destination_key(type, events)
      [
        Minuteman::PREFIX,
        BIT_OPERATION_PREFIX,
        type,
        events.join("-")
      ].join("_")
    end
  end
end
