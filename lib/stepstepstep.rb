# encoding: UTF-8

# TODO no return in step, cause it's a controller filter. Maybe inspect method source

require 'digest/sha1'

# 1. assign step's block to a method
# 2. extract all steps from before_filters and resort!
# 3. repush these steps back to before_filter

# every step is a normal controller method
# (register & adjust by score) & repeat

module Stepstepstep
  extend ActiveSupport::Concern

  module ClassMethods
    @@_step_to_ref_count ||= {}
    @@_steps_set ||= Set.new

    def step(opts, &blk)
      name = Array(opts).flatten.first
      @@_steps_set.add name
      @@_step_to_ref_count[name] ||= 0
      if opts.is_a?(Hash)
        # add to ref count
        Array(opts[name]).each do |__step_name|
          @@_step_to_ref_count[__step_name] ||= 0
          @@_step_to_ref_count[__step_name] += 1
        end
      end

      if @@_steps_set.include? name.to_sym
        blk ||= (Proc.new {})
        define_method(name, blk)
      else
        Rails.logger.info "#{self.class.name}##{name} is already defined!"
      end

      # 1. append first
      send(:before_filter, name.to_sym, :only => :index)

      # 2. extract all
      # self.new._process_action_callbacks.map(&:filter).select do |f|
      # self._process_action_callbacks.map(&:filter).select do |f|
      @@_steps_set.each {|_name| self.skip_filter _name }

      # 3. sort
      @@_steps_set.sort do |a, b|
        @@_step_to_ref_count[b] <=> @@_step_to_ref_count[a]
      end.each do |_name|
        # 4. reappend all
        opts = {}
        self.send(:before_filter, _name, :only => :index)
      end
    end

  end

end
