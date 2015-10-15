require 'minuteman/model'
require 'minuteman/analyzable'

module Minuteman
  class Event < Minuteman::Model
    include Minuteman::Analyzable

    def setbit(int)
      Minuteman.config.redis.call("SETBIT", key, int, 1)
    end
  end
end
