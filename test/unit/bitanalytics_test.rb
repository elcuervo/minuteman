require_relative "../test_helper"

describe BitAnalytics do
  before do
    @analytics = BitAnalytics.new
  end

  after do
    @analytics.reset_all
  end

  it "should initialize correctly" do
    assert @analytics.redis
  end

  it "should track an event on a time" do
    today = Time.now.utc
    last_month = today - (3600 * 24 * 30)
    last_week =  today - (3600 * 24 * 7)

    @analytics.mark("login", 12)
    @analytics.mark("login", 2, last_week)
    @analytics.mark("login:successful", 567, last_month)

    week_events = @analytics.week("login", today)
    last_week_events = @analytics.week("login", last_week)
    month_events = @analytics.month("login", today)
    last_month_events = @analytics.month("login:successful", last_month)

    assert month_events.include?(12)
    assert week_events.include?(12)
    assert last_week_events.include?(2)
    assert !month_events.include?(5)
    assert last_month_events.include?(567)
  end
end
