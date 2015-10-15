require 'minuteman/model'

module Minuteman
  class Counter < Minuteman::Model
    def incr
      Minuteman.config.redis.call("INCR", key)
    end

    def count
      Minuteman.config.redis.call("GET", key).to_i
    end
  end
end
