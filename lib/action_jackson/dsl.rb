# encoding: UTF-8

# TODO no return in step, cause it's a controller filter. Maybe inspect method source

module ActionJackson
  extend ActiveSupport::Concern

  module ClassMethods
    @@_step_deps ||= {}

    @@_is_action_jackson_load = false
    if !@@_is_action_jackson_load && !ENV['loading_steps']
      ENV['loading_steps'] = 'true'
      #controller_file = caller.grep(/_controller.rb|_controller_spec.rb/).grep(/include/)[0].split(":")[0]
      #Object.class_eval File.read(controller_file).gsub(/include +ActionJackson/, '')
      # require 'pry-debugger'; binding.pry

      @@_step_deps.each do |dependent, dependencies|
        case dependencies
        when Symbol
          register_step(dependent, dependencies)
        when Array
          dependencies.each do |dependency|
            register_step(dependent, dependency)
          end
        end
      end

      ENV.delete 'loading_steps'
    end

    def step(opts, &block)
      @@_step_deps ||= {}

      case opts
      when String
        return super(opts)
      when Symbol
        name = opts
      when Hash
        name = opts.keys.first
        @@_step_deps[name] = opts[name]
      end

      if self.methods.include? name.to_sym
        Rails.logger.warn "#{self.class.name}##{name} is already defined!"
      else
        block ||= (Proc.new {})
        define_method(name, block)
      end
    end

    def register_step(dependent, dependency)
      case @@_step_deps[dependency].class
      when String
        register_step(dependency, @@_step_deps[dependency])
      when Array
        @@_step_deps[dependency].each do |dependencydependency|
          register_step(dependency, dependencydependency)
        end
      end
      send(:before_filter, dependency, :only => dependent)
    end

    alias :action :step
    alias :filter :step
  end

end
