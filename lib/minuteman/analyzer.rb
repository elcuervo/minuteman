require 'minuteman/event'

module Minuteman
  Analyzer = Struct.new(:action) do
    def day(time = Time.now.utc)
      key = Minuteman.patterns[:day].call(time)
      Minuteman::Event.find_or_create(type: action, time: key)
    end
  end
end
