require 'minuteman/event'

module Minuteman
  Analyzer = Struct.new(:action) do
    def day(time = Time.now.utc)
      key = Minuteman.patterns[:day].call(time)
      Minuteman::Event.wrap(action, key)
    end
  end
end
