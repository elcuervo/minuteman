class Minuteman
  class Minute < TimeSpan
    def time_format(date)
      full_date = DATE_FORMAT % [date.year, date.month, date.day]
      time = TIME_FORMAT % [date.hour, date.min]
      [full_date + " " + time]
    end
  end
end
