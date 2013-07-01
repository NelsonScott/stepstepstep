# encoding: UTF-8

require 'spec_helper'

# https://www.relishapp.com/rspec/rspec-rails/docs/controller-specs/engine-routes-for-controllers

module Dummy
  class Application < Rails::Application
  end
end

class FooController < ActionController::Base

  # Fix In order to use #url_for, you must include routing helpers explicitly. For instance, `include Rails.application.routes.url_helpers
  # thx https://github.com/apotonick/apotomo/issues/35#issuecomment-3936941
  include Rails.application.routes.url_helpers
  def _routes; ::Rails.application.routes end
  def controller; parent_controller end


  include ActionJackson
  step :one do
    @a = [1]
  end
  step :one_point_three => :one do
    @a << 1.3
  end
  step :one_point_seven => :one do
    @a << 1.7
  end
  step :two => :one_point_seven do
    @a << 2
  end
  action :index => :two

  def index
    render :text => @a.inspect; return false
  end
end


Dummy::Application.routes.draw do
  resources :foo, :only => [:index]
end

describe FooController do
  describe "GET #index" do
    it "@a is sort correctly" do
      get :index
      response.body.should == "[1, 1.3, 1.7, 2]"
    end
  end
end
