$:.unshift File.dirname(__FILE__) + '/../lib'

require "bundler/setup"
require "minitest/spec"
require "minitest/pride"
require "minitest/given"
require "minitest/autorun"
require "minuteman"
require "redis-namespace"

Minuteman.redis = Redis.new
