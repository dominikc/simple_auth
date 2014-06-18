require "simple_auth"

RSpec.configure do |config|
end

class TestRequest
  attr_accessor :controller, :action, :user
  def initialize(controller = 'pages', action = 'index')
    @controller = controller
    @action     = action
  end

  def params
    { "controller" => @controller, "action" => @action }
  end
end

class Policy
  include SimpleAuth::Policy

  def rules
    foo_controller do
      deny notice: "Access denied", only: [:index, :show]
    end

    bar_controller do
      allow except: [:create, :destroy]
    end

    hello_controller do
      allow
      deny except: [:create, :destroy]
    end

    admin_controller do
      allow if call { @user == :admin }
    end

  end
end
