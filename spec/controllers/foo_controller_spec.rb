# encoding: UTF-8

require 'spec_helper'

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

Dummy::Application.routes.draw do
  [:bar, :remove, :after_remove, :insert, :sub2].each do |s|
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

describe FooController do
  it "@a is sort correctly" do
    callbacks = FooController.new._process_action_callbacks
    puts "FooController.new._process_action_callbacks.size is #{callbacks.size}, filters are #{callbacks.map(&:filter)}"

    get :index
    response.body.should == [1, 1.3, 1.7, 2].inspect
  end

  it "@a should skip 1.7" do
    get :another
    response.body.should == [1, 1.3, 2, "another"].inspect
  end
end

describe RemoveController do
  it "remove one step" do
    get :index
    response.body.should == [1, 1.7, 2].inspect
  end
end
describe AfterRemoveController do
  it "after remove one step" do
    get :index
    response.body.should == [1, 1.3, 1.7, 2].inspect
  end
end

describe InsertController do
  it "Insert one step" do
    get :index
    response.body.should == [1, 1.1, 1.3, 1.7, 2].inspect
  end
end

describe SubController do
  it "only should be skiped" do
    get :index
    response.body.should == [1, 1.3, 1.7, 2].inspect
  end
  it "only another" do
    get :another
    response.body.should == [1, 1.3, 2, 3, "another"].inspect
  end
end

describe Sub2Controller do
  it "one_point_three should be excepted" do
    get :index
    response.body.should == [1, 1.7, 2].inspect
  end
end
