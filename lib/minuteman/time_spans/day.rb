class Minuteman
  class Day < TimeSpan
    private

    # Private: The format that's going the be used for the date part of the key
    #
    #   date       - A given Time object
    #
    def time_format(date)
      [DATE_FORMAT % [date.year, date.month, date.day]]
    end
  end
end
