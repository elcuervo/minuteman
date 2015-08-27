require 'minuteman'
require 'minuteman/analyzable'

module Minuteman
  TimeSpan = Struct.new(:action, :key) do
    include Minuteman::Analyzable

    def count
      event = Minuteman::Event.new(action, key)
      Minuteman.redis.call("BITCOUNT", event)
    end
  end
end
