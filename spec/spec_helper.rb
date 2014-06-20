require "simple_auth"

RSpec.configure do |config|
end

class TestRequest
  attr_accessor :controller, :action, :user
  def initialize(controller, action)
    @controller = controller
    @action     = action
  end

  def params
    { "controller" => @controller, "action" => @action }
  end
end

class Policy
  include SimpleAuth::Policy
end
