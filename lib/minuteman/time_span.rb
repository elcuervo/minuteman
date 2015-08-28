require 'minuteman'
require 'minuteman/analyzable'

module Minuteman
  TimeSpan = Struct.new(:action, :key) do
    include Minuteman::Analyzable

    def count
      Minuteman.redis.call("BITCOUNT", id)
    end
  end
end
