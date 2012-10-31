class Minuteman
  class Month < TimeSpan
    private

    # Private: The format that's going the be used for the date part of the key
    #
    #   date       - A given Time object
    #
    def time_format(date)
      [date.year, "%02d" % date.month]
    end
  end
end
