# encoding: UTF-8

module Stepstepstep
  extend ActiveSupport::Concern

  # copied from http://ruby-doc.org/stdlib-1.9.3/libdoc/tsort/rdoc/TSort.html
  require 'tsort'
  class StepsInTSort < Hash
    include TSort
    alias tsort_each_node each_key
    def tsort_each_child(node, &block)
      (self[node] || []).each(&block)
    end
  end

  included do
    cattr_accessor :_steps_set, :_step_to_deps, :_before_filter_opts_hash
    self._steps_set ||= Set.new
    self._step_to_deps ||= StepsInTSort.new
    self._before_filter_opts_hash ||= Hash.new { Hash.new }
  end

  module ClassMethods
    def step(opts, opts2 = nil, &blk)
      # adjust params
      opts = opts2.merge(opts => nil) if opts2.is_a?(Hash)

      # prepare data
      __opts = {}
      if opts.is_a?(Hash)
        [:only, :except, :if].each do |symbol|
          __opts[symbol] = opts.delete(symbol) if opts[symbol]
        end
        step_name, __deps = opts.first
        step_name = step_name.to_sym
        add_step_to_dep step_name, __deps
        self._before_filter_opts_hash[step_name] = __opts
      elsif opts.is_a?(Symbol) || opts.is_a?(String)
        step_name = opts.to_sym
        add_step_to_dep step_name
      else
        raise "Please use Hash, Symbol, String for opts"
      end

      # define method
      if self._steps_set.include?(step_name)
        if not self.instance_methods.include?(step_name)
          blk ||= (Proc.new {})
          define_method(step_name, blk)
        else
          Rails.logger.info "#{self.class.name}##{step_name} is already defined!"
        end
      end

      # 1. append first
      send(:before_filter, step_name, self._before_filter_opts_hash[step_name])

      # 2. extract all
      self._steps_set.each {|n1| self.skip_before_filter n1 }

      # 3. resort
      _steps = self._step_to_deps.tsort
      _steps.each do |n1|
        # 4. reappend all
        if self.instance_methods.include?(n1)
          puts "filter to opts: #{n1}, #{self._before_filter_opts_hash}" if ENV['DEBUG_STEPSTEPSTE']
          self.send(:before_filter, n1, self._before_filter_opts_hash[n1])
        end
      end
    end

    private
    def add_step_to_dep n1, deps = nil
      self._steps_set.add n1

      deps = Array(deps).compact
      deps.each {|i| self._steps_set.add i }

      self._step_to_deps[n1] = deps
    end
  end

end
