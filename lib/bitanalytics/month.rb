class BitAnalytics
  class Month < TimeSpan
    def time_format(date)
      [date.year, date.month]
    end
  end
end
