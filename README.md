#form_journey

Include the `FormJourney::Controller` module to any Rails controller to create a multi page form.

```ruby
class UserSignupController < ApplicationController
  include FormJourney::Controller
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

  private

  def user_params
    # Any value in the "post" params will be included on the "journey_params" and kept in session
    journey_params.require(:user).permit(:name, :email)
  end
end
```

###Using journey parameters

```ruby
# journey_params
# {
#   action: 'signup',
#   controller: 'user_signup',
#   user: {
#     name: 'John Smith',
#     email: 'john@example.com'
#   }
# }

journey_params.get(:user) #=> { name: '...', email: '...' }
journey_params.get(:user, :name) #=> John Smith
journey_params.get(:user, :email) #=> 'john@example.com'
journey_params.get(:user, :address) #=> nil
journey_params.get(:user, :image, :url) #=> nil

journey_params.del(:user, :name) #=> 'John Smith'
journey_params.del(:user, :address) #=> nil

journey_params.set(:user, :address, value: 'Regent Street')

journey_params.require(:user).permit(:name, :email) #=> { user: { name: '...', email: '...' } }

# To clear the params
journey_params.clear_session
```

###Routes
Define journey routes using the `mount_journey` method.

```ruby
mount_journey 'user_signup', :user_signup

user_signup_step_path(:personal) #=> '/user_signup/personal'
```
