class Minuteman
  class Year < TimeSpan
    def time_format(date)
      [date.year]
    end
  end
end
