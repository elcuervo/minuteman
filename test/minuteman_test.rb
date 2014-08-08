$: << '../lib'

require 'cutest'
require 'minuteman'

setup do
  Minuteman.redis = Redic.new("redis://127.0.0.1:6379/0")
end

test "a connection" do
  assert Minuteman.redis.is_a?(Redic)
end
