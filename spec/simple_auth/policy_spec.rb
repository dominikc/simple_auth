require "spec_helper"

describe Policy do
  before(:each) do
    @policy = Policy.new(TestRequest.new)
  end
  
  it "denies every request by default" do
    class MyPolicy
      include SimpleAuth::Policy
    end
    
    @my_policy = MyPolicy.new(TestRequest.new)
    expect(@my_policy.denied?).to eq(true)
  end
  
  it "denies requests with notice" do
    @policy.context = TestRequest.new("foo", "index")
    expect(@policy.denied?).to eq(true)
    expect(@policy.notice).to eq("Access denied")
  end
  
  it "allows requests" do
    @policy.context = TestRequest.new("bar", "index")
    expect(@policy.denied?).to eq(false)
  end
  
  it "denies user requests within AdminController" do
    @policy.context = TestRequest.new("admin", "index")
    @policy.context.user = :user
    expect(@policy.denied?).to eq(true)
  end
  
  it "allows admin requests within AdminController" do
    @policy.context = TestRequest.new("admin", "index")
    @policy.context.user = :admin
    expect(@policy.allowed?).to eq(true)
  end
  
  it "allows requests except :create and :destroy" do
    cases = {index: true, create: false, show: true, destroy: false}
    
    cases.each do |action, value|
      @policy.context = TestRequest.new("bar", action)
      expect(@policy.allowed?).to eq(value)
    end
  end
  
  it "denies requests except :create and :destroy" do
    cases = {index: true, create: false, show: true, destroy: false}
    
    cases.each do |action, value|
     @policy.context = TestRequest.new("hello", action)
    end
  end
  
end