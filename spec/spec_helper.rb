# encoding: UTF-8

require 'active_support/core_ext'
require 'action_controller'
require 'active_model'
require 'rails/all'


require 'rspec/rails'
require 'pry-debugger'
require File.join(ENV['HOME'], 'utils/ruby/irb.rb') rescue nil

$:.push File.expand_path("../../lib", __FILE__)
require 'stepstepstep'

Rails.logger ||= Logger.new($stderr)
ENV['DEBUG_STEPSTEPSTE'] = 'true' if `whoami`.strip == 'mvj3'
