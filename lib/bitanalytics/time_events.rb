require "bitanalytics/time_span"
require "bitanalytics/month"
require "bitanalytics/week"
require "bitanalytics/day"

class BitAnalytics
  module TimeEvents
    def self.start(redis, event_name, time)
      [Month, Week, Day].map { |t| t.new(redis, event_name, time) }
    end
  end
end
