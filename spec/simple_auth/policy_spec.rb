require "spec_helper"

describe Policy do
  let(:policy) { Policy.new(TestRequest.new('pages', 'index')) }

  it "denies every request by default" do
    class MyPolicy
      include SimpleAuth::Policy
    end

    my_policy = MyPolicy.new(TestRequest.new('pages', 'index'))
    expect(my_policy).to be_denied
  end

  it "denies requests with notice" do
    policy.instance_eval do
      pages_controller do
        deny notice: "Access denied", only: [:index, :show]
      end
    end

    expect(policy).to be_denied
    expect(policy.notice).to eq("Access denied")
  end

  it "allows requests" do
    policy.instance_eval do
      pages_controller do
        allow except: [:create, :destroy]
      end
    end

    expect(policy).not_to be_denied
  end

  it "allows requests within PagesController" do
    policy.instance_eval do
      allow only: [:pages]
    end

    expect(policy).to be_allowed
  end

  it "denies user requests within AdminController" do
    policy.context = TestRequest.new("admin", "index")
    policy.instance_eval do
      admin_controller do
        allow if call { @user == :admin }
      end
    end

    policy.context.user = :user
    expect(policy).to be_denied
  end

  it "allows admin requests within AdminController" do
    policy.context = TestRequest.new("admin", "index")
    policy.instance_eval do
      admin_controller do
        allow if call { @user == :admin }
      end
    end

    policy.context.user = :admin
    expect(policy).to be_allowed
  end

  it "allows requests except :create and :destroy" do
    cases = {index: true, create: false, show: true, destroy: false}
    policy.instance_eval do
      example_controller do
        allow except: [:create, :destroy]
      end
    end

    cases.each do |action, value|
      policy.context = TestRequest.new("example", action)
      expect(policy.allowed?).to eq(value)
    end
  end

  it "denies requests except :create and :destroy" do
    policy.instance_eval do
      example_controller do
        allow
        deny except: [:create, :destroy]
      end
    end

    cases = {index: true, create: false, show: true, destroy: false}

    cases.each do |action, value|
      policy.context = TestRequest.new("example", action)
      expect(policy.denied?).to eq(value)
    end
  end

end
