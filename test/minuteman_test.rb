require 'helper'

setup do
  Minuteman.redis = Redic.new("redis://127.0.0.1:6379/1")
  Minuteman.redis.call("FLUSHDB")
end

test "a connection" do
  assert_equal Minuteman.redis.class, Redic
end

test "models in minuteman namespace" do
  assert_equal Minuteman::User.create.key, "Minuteman::User:1"
end

test "an anonymous user" do
  user = Minuteman::User.create

  assert user.is_a?(Minuteman::User)
  assert !!user.uid
  assert !user.identifier
  assert user.id
end

test "access a user with and id or an uuid" do
  user = Minuteman::User.create(identifier: 5)

  assert Minuteman::User[user.uid].is_a?(Minuteman::User)
  assert Minuteman::User[user.identifier].is_a?(Minuteman::User)
end

test "track an anonymous user" do
  user = Minuteman.track("unknown")
  assert user.uid
end

test "track an user" do
  user = Minuteman::User.create

  assert Minuteman.track("login:successful", user)

  analyzer = Minuteman.analyze("login:successful")
  assert analyzer.day(Time.now.utc).count == 1
end

test "tracks an anonymous user and the promotes it to a real one" do
  user = Minuteman.track("enter:website")
  assert user.identifier == nil

  user.promote(42)

  assert user.identifier == 42
  assert Minuteman::User[42].uid == user.uid
end

test "use the method shortcut" do
  5.times { Minuteman.track("enter:website") }

  assert Minuteman("enter:website").day.count == 5
end

test "operation AND" do
  users = Array.new(3) { Minuteman::User.create }
  users.each do |user|
    Minuteman.track("landing_page:new", users)
  end

  Minuteman.track("buy:product", users[0])
  Minuteman.track("buy:product", users[2])

  and_op = Minuteman("landing_page:new").day & Minuteman("buy:product").day
  assert and_op.count == 2
end

test "operation OR" do
  users = Array.new(3) { Minuteman::User.create }
  users.each do |user|
    Minuteman.track("landing_page:new", users)
  end

  Minuteman.track("buy:product", users[0])
  Minuteman.track("buy:product", users[2])

  or_op = Minuteman("landing_page:new").day | Minuteman("buy:product").day
  assert or_op.count == 3
end
