Stepstepstep
=================================================
Rails before_filters don't take it far enough. What stepstepstep allows you to do is define dependecies between your controller actions and before filters in the same way you do with rake tasks.


Install
-------------------------------------------------
Stick this in your Gemfile.
```ruby
gem 'stepstepstep'
```

Usage
-------------------------------------------------

#### Include the DSL

Might as well add it for all you controllers.
```ruby
class ApplicationController < ActionController::Base
  include Stepstepstep
end
```
    
Or you can do it on a per controller basis if you insist.

```ruby
class MyController < ApplicationController
  include Stepstepstep
end
```

#### Defineing Actions and Filters

Define your actions like this within your controller.

```ruby
step :index do
end
```
    
Need a before filter? Wire it up like this.

```
step :index => :load_user do
end

def load_user
  @user = User.find(params[:user_id])
end
```

which is equivalent to...

```
before_filter :load_user, :only => :index

def index
end

def load_user
  @user = User.find(params[:user_id])
end
```

But the fun doesn't stop there. We can define before filters for our before filters.

```
step :index => :load_user do
end

step :load_user => :some_other_filter do
end

def some_other_filter
end
```
    

Lastly, you can also define multiple dependencies with an Array and they'll be executed in the order they appear.

```
step :index => [:first_filter, :second_filter] do
end
```
  
Keep in mind actions can depend on steps, filters can depend on filters, steps on filters, on and on and so forth. The dependency heirarchy can get very deep and complicated, but thanks to stepstepstep your code doesn't have to.

### Gotchas

If you're using `return` in your actions you'll want to switch it out with `next` otherwise you'll receive an error.
    
```ruby
def index
  return unless param[:id]
  @item = Item.find(param[:id])
end
```

becomes...

```ruby
step :index do
  next unless param[:id]
  @item = Item.find(param[:id])
end
```
