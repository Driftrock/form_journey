require 'action_dispatch'

module ActionDispatch::Routing
  class Mapper
    def mount_journey(path, controller)
      get "#{path}", controller: controller, action: :default_step
      match "#{path}/:action", controller: controller, action: /[a-z0-9_]+/, via: [:get, :post], as: "#{path}_step"
    end
  end
end
