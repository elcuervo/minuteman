# Public: Minuteman core classs
#
class Minuteman
  # Public: Year TimeSpan class
  #
  class Year < TimeSpan
    private

    # Private: The format that's going the be used for the date part of the key
    #
    #   date       - A given Time object
    #
    def time_format(date)
      [date.year]
    end
  end
end
