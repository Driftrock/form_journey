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

###Single Model form journey

When using a single model on the form journey there is a helper module

```ruby
class UserSignupController < ApplicationController
  include FormJourney::Controller
  include FormJourney::UsesSingleModel
  steps :signup, :personal, :additional_information
  model_class User # also accepts a string representation of the constant
  params_method :user_params # also accepts a block

  private

  def user_params
    # Any value in the "post" params will be included on the "journey_params" and kept in session
    journey_params.require(:user).permit(:name, :email)
  end
end

This automatically creates an edit route and a helper method for getting
the current model instance based on the user params. The method to
retrieve the model instance is based on an underscored version of the model name:

```ruby

model_class User #=> helper_method :user
model_class MyUser #=> helper_method :my_user
model_class Admin::MyUser #=> helper_method :admin_my_user

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

journey_params.add_to_array(:user, :phone_numbers, value: '001') #=> ['001']
journey_params.add_to_array(:user, :phone_numbers, value: '002') #=> ['001', '002']
journey_params.add_to_array(:user, :phone_numbers, value: '002', unique: true) #=> ['001', '002']
journey_params.add_to_array(:user, :phone_numbers, value: '002') #=> ['001', '002', '002']
journey_params.remove_from_array(:user, :phone_numbers, value: '002') #=> ['001']

# To clear the params
journey_params.clear!
```

###Routes
Define journey routes using the `mount_journey` method.

```ruby
mount_journey 'user_signup', :user_signup

user_signup_step_path(:personal) #=> '/user_signup/personal'
```

Mount can also take a block

```ruby
mount_journey 'user_signup', :user_signup do
  get '/confirm_email', to: 'user_signup#confirm_email'
end
```
