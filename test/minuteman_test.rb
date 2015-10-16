require 'helper'

@patterns = Minuteman.patterns

prepare do
  Minuteman.configure do |config|
    config.redis = Redic.new("redis://127.0.0.1:6379/1")
  end
end

setup do
  Minuteman.config.redis.call("FLUSHDB")

  Minuteman.configure do |config|
    config.patterns = @patterns
  end
end

test "a connection" do
  assert_equal Minuteman.config.redis.class, Redic
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
  user = Minuteman.track("anonymous:user")
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
  Minuteman.configure do |config|
    config.patterns = {
      dia: -> (time) { time.strftime("%Y-%m-%d") }
    }
  end

  Minuteman.track("logeo:exitoso")
  assert Minuteman("logeo:exitoso").dia.count == 1
end

test "use the method shortcut" do
  5.times { Minuteman.track("enter:website") }

  assert Minuteman("enter:website").day.count == 5
end

scope "operations" do
  setup do
    Minuteman.config.redis.call("FLUSHDB")

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

scope "complex operations" do
  setup do
    Minuteman.config.redis.call("FLUSHDB")
    @users = Array.new(6) { Minuteman::User.create }

    [ @users[0], @users[1], @users[2] ].each do |u|
      Minuteman.track("promo:email", u)
    end

    [ @users[3], @users[4], @users[5] ].each do |u|
      Minuteman.track("promo:facebook", u)
    end

    [ @users[1], @users[4], @users[6] ].each do |u|
      Minuteman.track("user:new", u)
    end
  end

  test "verbose" do
    got_promos = Minuteman("promo:email").day + Minuteman("promo:facebook").day

    @users[0..5].each do |u|
      assert got_promos.include?(u)
    end

    new_users = Minuteman("user:new").day
    query = got_promos & new_users

    [ @users[1], @users[4] ].each do |u|
      assert query.include?(u)
    end

    assert query.count == 2
  end

  test "readable" do
    query = (
      Minuteman("promo:email").day + Minuteman("promo:facebook").day
    ) & Minuteman("user:new").day

    assert query.count == 2
  end
end

test "count a given event" do
  10.times { Minuteman.add("enter:new_landing") }

  assert Counterman("enter:new_landing").day.count == 10
end

test "count events on some dates" do
  day = Time.new(2015, 10, 15)
  next_day = Time.new(2015, 10, 16)

  5.times { Minuteman.add("drink:beer", day) }
  2.times { Minuteman.add("drink:beer", next_day) }

  assert Counterman("drink:beer").month(day).count == 7
  assert Counterman("drink:beer").day(day).count == 5
end

scope "do actions through a user" do
  test "track an event" do
    user = Minuteman::User.create
    user.track("login:page")

    3.times { user.add("login:attempts") }
    2.times { Minuteman.add("login:attempts") }

    assert Minuteman("login:page").day.include?(user)
    assert Counterman("login:attempts").day.count == 5
    assert user.count("login:attempts").day.count == 3
  end
end
