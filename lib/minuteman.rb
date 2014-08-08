require 'redic'

module Minuteman
  class << self
    def redis
      @_redis ||= Redic.new
    end

    def redis=(redis)
      @_redis = redis
    end
  end
end
