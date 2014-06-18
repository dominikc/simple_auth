# SimpleAuth

Simple authentication library for Ruby on Rails.
It allows to restrict controllers and views using simple rules which are definied in a single file.

## Installation

Add this line to your application's Gemfile:

    gem 'simple_auth', :git => "git://github.com/dominikc/simple_auth.git"

And then execute:

    $ bundle
    
## Usage

### 1. Define abilities and permissions

    class Policy
      include SimpleAuth::Policy
      
      def rules
        allow
      end
    end


### 2. Set up your controllers

Set a filter on `ApplicationController`

    class ApplicationController < ActionController::Base
      before_filter :check_policy
      
      private
      def check_policy
        if Policy.new(self).denied?
          render status: :forbidden, text: "403 forbidden" 
        end
      end
    end
    
    
Or override `devise` method:
    
    class ApplicationController < ActionController::Base
      def authenticate_user!
        super
        if Policy.new(self).denied?
          render status: :forbidden, text: "403 forbidden" 
        end
      end
    end

## Methods

### The `allow` and `deny` methods
    def rules
      allow
      allow only: [:index, :show]
      allow except [:create, :destroy]

      deny
      deny notice: "Access denied"
      deny only: [:index, :show]
      deny except [:create, :destroy]
    end


### Dynamic methods

    def rules

      pages_controller { allow }
      
      example_controller do
        index { allow }
        show { deny }
      end
      
      foo_controller :bar
      
      def bar
        allow
      end
    end

### Controller
To access controller methods and variables use `call` method:

    @user = call { current_user }
    

### Authenticate controller

    def rules
      allow
    end
    
    Policy.new(self).allowed? # => true
    Policy.new(self).denied?  # => false
    
### Display notice
To display notice use `notice` method:

    def rules
      deny notice: "Access denied"
    end

    @policy = Policy.new(self).auth
    @notice = @policy.notice

### Scopes
Rules are inherited, to override them use dynamic methods


    def rules
      allow # first scope
      
      pages_controller do
        deny # second scope
        
        index do
          allow # third scope
        end
      end
    end
      
## Sample policy.rb file
  
  
    class Policy
      include SimpleAuth::Policy
    
      def rules
        @user = call { current_user }
    
        allow only: [:hello, :world]
        deny except: [:ruby, :rails]
      
        pages_controller do
          allow if @user
          
          dashboard do
            if @user
              allow
            else
              deny notice: "Sign in to continue"
            end
          end
        end
      
        admin_controller :is_admin?
      end
    
      def is_admin?
        @user.roles.include? :admin
      end
    end

## Contributing

1. Fork it ( https://github.com/dominikc/simple_auth/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
