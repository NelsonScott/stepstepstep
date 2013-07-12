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


# https://www.relishapp.com/rspec/rspec-rails/docs/controller-specs/engine-routes-for-controllers

module Dummy
  class Application < Rails::Application
  end
end

class BarController < ActionController::Base
  # Fix In order to use #url_for, you must include routing helpers explicitly. For instance, `include Rails.application.routes.url_helpers
  # thx https://github.com/apotonick/apotomo/issues/35#issuecomment-3936941
  # TODO blankslate.rails_engine.rspec.gem
  include Rails.application.routes.url_helpers
  def _routes; ::Rails.application.routes end
  def controller; parent_controller end

end

class FooController < BarController
  include Stepstepstep

  step :two => [:one_point_three, :one_point_seven] do
    @a << 2
  end
  step :one_point_three => :one do
    @a << 1.3
  end
  step :one do
    @a = [1]
  end
  step :one_point_seven => :one_point_three, :only => :index do
    @a << 1.7
  end

  def index
    render :inline => @a.inspect
  end

  def another
    @a << 'another'
    render :inline => @a.inspect
  end
end


class NextController < FooController
  step :test_next_with_three => :two do
    next if true
    @a << 3
  end
end

class RemoveController < FooController
  skip_filter :one_point_three
end
class AfterRemoveController < FooController
end
class InsertController < FooController
  step :one_point_one => :one do
    @a << 1.1
  end
  step :one_point_three => :one_point_one
end
class SubController < FooController
  step :only_action => :two, :only => :another do
    @a << 3
  end

  def another
    @a << 'another'
    render :inline => @a.inspect
  end
end
class Sub2Controller < SubController
  step :one_point_three, :except => [:index]
  step :two => [:one, :one_point_seven] # remember to connect the broken edges
end

class RedirectToController < FooController
  def index
    redirect_to "/redirect_to" and return
  end
end

Dummy::Application.routes.draw do
  [:bar, :remove, :after_remove, :insert, :sub2, :redirect_to, :next].each do |s|
    resources s
  end
  [:foo, :sub].each do |r|
    resources r do
      collection do
        get :another
      end
    end
  end
end


