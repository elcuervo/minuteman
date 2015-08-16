require 'minuteman/time_span'

module Minuteman
  Analyzer = Struct.new(:action) do
    def day(time)
      Minuteman::TimeSpan.new(action, time)
    end
  end
end
