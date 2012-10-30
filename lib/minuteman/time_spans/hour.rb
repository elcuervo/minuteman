class Minuteman
  class Hour < TimeSpan
    def time_format(date)
      full_date = DATE_FORMAT % [date.year, date.month, date.day]
      time = TIME_FORMAT % [date.hour, 0]
      [full_date + " " + time]
    end
  end
end
