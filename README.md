#form_journey

Include the `FormJourney::Controller` module to any Rails controller to create a multi page form.

```ruby
class UserSignupController < ApplicationController
  include FormJourney::Controller
  include FormJourney::Parameters
  steps :signup, :personal, :additional_information

  def signup
    when_post do
      redirect_to next_step_path
    end
  end

  def personal
  end

  def additional_information
  end
end
```

###Using journey parameters
You must have included the `FormJourney::Parameters` to use it.

```ruby
# journey_params
# {
#   'action' => 'signup',
#   'controller' => 'user_signup',
#   'user' => {
#     'name' => 'John Smith',
#     'email' => 'john@example.com'
#   }
# }

get_journey_param(:user) #=> { 'name' => 'John Smith' ... }
get_journey_param(:user, :name) #=> John Smith
get_journey_param(:user, :email) #=> 'john@example.com'
get_journey_param(:user, :address) #=> nil
get_journey_param(:user, :image, :url) #=> nil

del_journey_param(:user, :name) #=> 'John Smith'
del_journey_param(:user, :address) #=> nil

journey_params #=> { ..., 'user' => { 'email' => 'john@example.com' } }
```

###Routes
Define journey routes using the `mount_journey` method.

```ruby
mount_journey 'user_signup', :user_signup

user_signup_step_path(:personal) #=> '/user_signup/personal'
```
