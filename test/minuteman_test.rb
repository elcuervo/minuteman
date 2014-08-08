$: << '../lib'

require 'cutest'
require 'minuteman'

setup do
  Minuteman.redis = Redic.new("redis://127.0.0.1:6379/1")
  Minuteman.redis.call("FLUSHDB")
end

test "a connection" do
  assert Minuteman.redis.is_a?(Redic)
end

test "an anonymous user" do
  user = Minuteman::User.create

  assert user.is_a?(Minuteman::User)
  assert !!user.uid
  assert !user.identifier
  assert user.id
end
