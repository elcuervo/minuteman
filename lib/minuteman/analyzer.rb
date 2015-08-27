require 'minuteman/time_span'

module Minuteman
  Analyzer = Struct.new(:action) do
    def day(time = Time.now.utc)
      key = Minuteman.patterns[:day].call(time)
      Minuteman::TimeSpan.new(action, key)
    end
  end
end
