require 'helper'

setup do
  Minuteman.redis = Redic.new("redis://127.0.0.1:6379/1")
  Minuteman.redis.call("FLUSHDB")
end

test "a connection" do
  assert_equal Minuteman.redis.class, Redic
end

test "models in minuteman namespace" do
  assert_equal Minuteman::User.create.key, "minuteman:Minuteman::User:1"
end

test "an anonymous user" do
  user = Minuteman::User.create

  assert user.is_a?(Minuteman::User)
  assert !!user.uid
  assert !user.identifier
  assert user.id
end

test "access a user" do
  user = Minuteman::User.create(id: 5)

  assert Minuteman::User[user.uid].is_a?(Minuteman::User)
  assert Minuteman::User[user.id].is_a?(Minuteman::User)
end

test "track an user" do
  assert Minuteman.track("login:successful", Minuteman::User.create)
end
