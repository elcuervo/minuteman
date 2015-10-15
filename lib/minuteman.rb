require 'redic'

module Minuteman
  LUA_CACHE      = Hash.new { |h, k| h[k] = Hash.new }
  LUA_OPERATIONS = File.expand_path("../minuteman/lua/operations.lua",   __FILE__)

  class << self
    def config
      @_configuration ||= Configuration.new
    end

    def configure
      yield(config)
    end

    def prefix
      config.prefix
    end

    def patterns
      config.patterns
    end

    def time_spans
      @_time_spans = patterns.keys
    end

    def track(action, users = nil, time = Time.now.utc)
      users = Minuteman::User.create if users.nil?

      Array(users).each do |user|
        time_spans.each do |time_span|
          event = Minuteman::Event.create(
            type: action,
            time: patterns[time_span].call(time)
          )

          event.setbit(user.id)
        end
      end

      users
    end

    def analyze(action)
      analyzers_cache[action]
    end

    private

    def analyzers_cache
      @_analyzers_cache ||= Hash.new { |h,k| h[k] = Minuteman::Analyzer.new(k) }
    end
  end
end

def Minuteman(action)
  Minuteman.analyze(action)
end

require 'minuteman/user'
require 'minuteman/event'
require 'minuteman/result'
require 'minuteman/analyzer'
require 'minuteman/configuration'
