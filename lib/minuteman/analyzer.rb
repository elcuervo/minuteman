require 'minuteman/time_span'

module Minuteman
  Analyzer = Struct.new(:action) do
    def day(time = Time.now.utc)
      Minuteman::TimeSpan.new(action, time)
    end
  end
end
