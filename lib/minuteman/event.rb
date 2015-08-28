require 'minuteman/model'
require 'minuteman/analyzable'

module Minuteman
  class Event < Minuteman::Model
    include Minuteman::Analyzable

    attribute :type
    attribute :time

    def self.wrap(type, time)
      new(type: type, time: time)
    end

    def key
      "#{self.class}::#{type}:#{time}"
    end

    def setbit(int)
      Minuteman.redis.call("SETBIT", key, int, 1)
    end
  end
end
