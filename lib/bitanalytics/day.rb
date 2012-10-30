class BitAnalytics
  class Day < TimeSpan
    def time_format(date)
      [date.year, date.month, date.day]
    end
  end
end
