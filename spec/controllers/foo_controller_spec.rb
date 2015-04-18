# encoding: UTF-8

require 'spec_helper'


describe FooController do
  it "@a is sort correctly" do
    callbacks = FooController.new._process_action_callbacks
    puts "FooController.new._process_action_callbacks.size is #{callbacks.count}, filters are #{callbacks.map(&:filter)}"

    get :index
    response.body.should == [1, 1.3, 1.7, 2].inspect
  end

  it "@a should skip 1.7" do
    get :another
    response.body.should == [1, 1.3, 2, "another"].inspect
  end
end

describe NextController do
  it "skip if next in step method" do
    get :index
    response.body.should == [1, 1.3, 1.7, 2].inspect
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


describe RedirectToController do
  it "support redirect_to" do
    get :index
    response.should redirect_to("/redirect_to")
  end
end
