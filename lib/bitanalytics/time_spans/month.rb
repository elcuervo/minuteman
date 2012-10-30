class BitAnalytics
  class Month < TimeSpan
    def time_format(date)
      [date.year, "%02d" % date.month]
    end
  end
end
