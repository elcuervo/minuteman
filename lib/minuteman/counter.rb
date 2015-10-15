require 'minuteman/model'

module Minuteman
  class Counter < Minuteman::Model
    class User < Counter
      attribute :user_id

      def key
        "#{super}:#{user_id}"
      end
    end

    def incr
      Minuteman.config.redis.call("INCR", key)
    end

    def count
      Minuteman.config.redis.call("GET", key).to_i
    end
  end
end
