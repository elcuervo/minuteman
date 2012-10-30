class BitAnalytics
  class Week < TimeSpan
    def time_format(date)
      week = date.strftime("%W")
      [date.year, "W" + week]
    end
  end
end
