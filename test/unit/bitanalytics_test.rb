require_relative "../test_helper"

describe BitAnalytics do
  before do
    @analytics = BitAnalytics.new
  end

  it "should initialize correctly" do
    assert @analytics.redis
  end

  it "should track an event" do
    @analytics.mark("login", 12)

    month_events = @analytics.month_events("login", Time.now.utc)
    assert month_events.include?(12)
    assert !month_events.include?(2)
  end
end
