# Public: Minuteman core classs
#
class Minuteman
  # Public: Month TimeSpan class
  #
  class Week < TimeSpan
    private

    # Private: The format that's going the be used for the date part of the key
    #
    #   date       - A given Time object
    #
    def time_format(date)
      week = date.strftime("%W")
      [date.year, "W" + week]
    end
  end
end
