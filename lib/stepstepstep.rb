# encoding: UTF-8

module Stepstepstep
  extend ActiveSupport::Concern

  module ClassMethods
    @@_steps_set ||= Set.new

    def step(opts, &blk)
      __before_filter_opts = {}
      if opts.is_a?(Hash)
        [:only, :except, :if].each do |symbol|
          __before_filter_opts[symbol] = opts.delete(symbol) if opts[symbol]
        end
        __name, __deps = opts.first
        add_step_to_dep __name, __deps
      elsif opts.is_a?(Symbol) || opts.is_a?(String)
        __name = opts.to_sym
      else
        raise "Please use Hash, Symbol, String for opts"
      end

      @@_steps_set.add __name

      if @@_steps_set.include? __name
        blk ||= (Proc.new {})
        define_method(__name, blk)
      else
        Rails.logger.info "#{self.class.name}##{__name} is already defined!"
      end

      # 1. append first
      send(:before_filter, name.to_sym, :only => :index)

      # 2. extract all
      @@_steps_set.each {|n1| self.skip_filter n1 }

      # 3. resort
      _steps = @@_steps_set.sort do |a, b|
        (@@_step_to_deps[a] || Set.new).size <=> (@@_step_to_deps[b] || Set.new).size
      end
      if ENV['DEBUG_STEPSTEPSTE']
      puts @@_step_to_deps.inspect
      puts _steps.inspect
      puts
      end
      _steps.each do |n1|
        # 4. reappend all
        opts = {}
        self.send(:before_filter, n1, __before_filter_opts)
      end
    end

    private
    def add_step_to_dep n1, deps
      @@_step_to_deps ||= {}

      Array(deps).each do |__dep1|
        @@_step_to_deps[n1] ||= Set.new
        @@_step_to_deps[n1].add __dep1

        @@_step_to_deps[__dep1].each do |__dep2|
          add_step_to_dep n1, __dep2
        end if @@_step_to_deps[__dep1]
      end
    end
  end

end
