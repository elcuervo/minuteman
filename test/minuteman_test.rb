require 'helper'

@patterns = Minuteman.patterns

prepare do
  Minuteman.redis = Redic.new("redis://127.0.0.1:6379/1")
end

setup do
  Minuteman.redis.call("FLUSHDB")
  Minuteman.patterns = @patterns
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
  assert Minuteman("enter:website").day.include?(user)
end

test "create your own storage patterns and access analyzer" do
  Minuteman.patterns = {
    dia: -> (time) { time.strftime("%Y-%m-%d") }
  }

  Minuteman.track("logeo:exitoso")
  assert Minuteman("logeo:exitoso").dia.count == 1
end

test "use the method shortcut" do
  5.times { Minuteman.track("enter:website") }

  assert Minuteman("enter:website").day.count == 5
end

scope "operations" do
  setup do
    Minuteman.redis.call("FLUSHDB")

    @users = Array.new(3) { Minuteman::User.create }
    @users.each do |user|
      Minuteman.track("landing_page:new", @users)
    end

    Minuteman.track("buy:product", @users[0])
    Minuteman.track("buy:product", @users[2])
  end

  test "AND" do
    and_op = Minuteman("landing_page:new").day & Minuteman("buy:product").day
    assert and_op.count == 2
  end

  test "OR" do
    or_op = Minuteman("landing_page:new").day | Minuteman("buy:product").day
    assert or_op.count == 3
  end

  test "XOR" do
    xor_op = Minuteman("landing_page:new").day ^ Minuteman("buy:product").day
    assert xor_op.count == 1
  end

  test "NOT" do
    assert Minuteman("buy:product").day.include?(@users[2])

    not_op = -Minuteman("buy:product").day
    assert !not_op.include?(@users[2])
  end

  test "MINUS" do
    assert Minuteman("landing_page:new").day.include?(@users[2])
    assert Minuteman("buy:product").day.include?(@users[2])

    minus_op = Minuteman("landing_page:new").day - Minuteman("buy:product").day

    assert !minus_op.include?(@users[2])
    assert minus_op.include?(@users[1])
  end
end
