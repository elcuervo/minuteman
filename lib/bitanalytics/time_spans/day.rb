class BitAnalytics
  class Day < TimeSpan
    def time_format(date)
      [DATE_FORMAT % [date.year, date.month, date.day]]
    end
  end
end
