require 'action_dispatch'

module ActionDispatch::Routing
  class Mapper
    def mount_journey(path, controller)
      resource "#{path}", only: [] do
        get "/", controller: controller, action: :default_step
        get "/:id/edit", controller: controller, action: 'edit', as: 'edit'
        yield if block_given?
        match "/:action", controller: controller, action: /[a-z0-9_]+/, via: [:get, :post, :patch, :delete], as: 'step'
      end
    end
  end
end
