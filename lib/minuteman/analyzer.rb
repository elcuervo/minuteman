require 'minuteman/time_span'

module Minuteman
  Analyzer = Struct.new(:action) do
    def day(time = Time.now.utc)
      Minuteman::TimeSpan.day(action, time)
    end
  end
end
