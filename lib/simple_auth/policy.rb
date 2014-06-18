module SimpleAuth
  module Policy
    def self.included(base)
      base.include InstanceMethods
    end
    
    module InstanceMethods
      attr_accessor :context, :notice
      def initialize(controller)
        @context     = controller
        @priority    = 0
        @controllers = {}
        @actions     = {}
        @allowed     = [{}, {}, {}]
        @denied      = [{}, {}, {}]
        @notice      = nil
        @validated   = false
        rules
      end
      
      def rules; end
      
      def method_missing(name, *args, &block)
        if name.to_s =~ /^(.+)_controller$/
          add_controller($1, *args, &block)
        else
          (block_given?) ? add_action(name, &block) : super
        end
      end
      
      def add_action(name, &block)
        @actions[name.to_s] = block
      end

      def add_controller(name, meth = nil, &block)
        if block_given?
          @controllers[name.to_s] = block
        else
          add_controller(name) { send(meth) }
        end
      end
      
      def call(&block)
        @context.instance_eval(&block)
      end

      def is_allowed(kind, i)
        allowed = :default
          unless @allowed[i].empty? && @denied[i].empty?
            a = check_statement(@allowed[i], kind)
            d = check_statement(@denied[i], kind)
            
            allowed = a && !d
          end

        allowed
      end
      
      def set_notice(controller, action)
        (0..2).each do |i|
          apply_notice = lambda do |str|
            @notice = str if str.kind_of? String
          end

          apply_notice.call(@denied[i][:all])
          apply_notice.call(@denied[i]["o_#{controller}"])
          apply_notice.call(@denied[i]["o_#{action}"])
        end
      end
      
      def check_statement(obj, kind)
        !obj[:all].nil? && obj["e_#{kind}"].nil? || !obj["o_#{kind}"].nil?
      end

      def allowed?
        auth(false)
      end
      
      def auth(return_self = true)
        controller, action = @context.params.values_at('controller', 'action')
        @priority = 1; @controllers[controller] && @controllers[controller].call
        @priority = 2; @actions[action] && @actions[action].call
        
        allowed = false
        
        (0..2).each do |i|
          c1 = is_allowed(controller, i)
          c2 = is_allowed(action, i)
          condition = @denied[i][:all] ? c1 || c2 : c1 && c2
          allowed = condition if condition != :default
        end
        
        set_notice(controller, action) unless allowed
        
        return_self ? self : allowed
      end
      
      def denied?
        !allowed?
      end

      def set_statement(obj, args)
        notice = args[:notice] || true
        
        if only = args[:only]
          only = [only] unless only.kind_of?(Array)
          only.each { |a| obj["o_#{a.to_s}"] = notice }
        else
          obj[:all] = true
          if except = args[:except]
            except = [except] unless except.kind_of?(Array)
            except.each { |a| obj["e_#{a.to_s}"] = true }
          end
        end
      end

      def deny(args = {})
        set_statement(@denied[@priority], args)
      end

      def allow(args = {})
        set_statement(@allowed[@priority], args)
      end
    end
  end
end