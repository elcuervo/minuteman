class Minuteman
  class Minute < TimeSpan
    private

    # Private: The format that's going the be used for the date part of the key
    #
    #   date       - A given Time object
    #
    def time_format(date)
      full_date = DATE_FORMAT % [date.year, date.month, date.day]
      time = TIME_FORMAT % [date.hour, date.min]
      [full_date + " " + time]
    end
  end
end
