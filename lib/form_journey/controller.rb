module FormJourney
  module Controller
    extend ActiveSupport::Concern

    included do
      class_attribute :_steps
      self._steps = []

      before_action :before_step_action
      helper_method :step_path
      helper_method :current_step_path
      helper_method :next_step_path
      helper_method :previous_step_path
      helper_method :current_step_number
      helper_method :total_steps_number

      [:current_step, :previous_step, :next_step].each do |key|
        class_eval do
          define_method "#{key}_path".to_sym do
            step_path(self.send(key))
          end
        end
      end
    end

    def default_step
      redirect_to steps.any? ? step_path(steps.first) : '/'
    end

    def steps
      instance_steps || self.class._steps
    end

    def instance_steps
      @instance_steps ||= nil
    end

    def update_steps(*new_steps)
      @instance_steps ||= previous_steps.concat(new_steps)
    end

    def step_path(step)
      url_for(controller: params[:controller], action: step)
    end

    def current_step
      steps.include?(params[:action].to_sym) and params[:action].to_sym or steps.first
    end

    def next_step
      steps[current_step_index + 1] || steps.last
    end

    def previous_step
      steps[current_step_index - 1] || steps.first
    end

    def current_step_number
      current_step_index + 1
    end

    def total_steps_number
      steps.count
    end

    def when_post
      return yield if request.post?
    end

    def when_patch
      return yield if request.patch?
    end

    def when_post_or_patch
      return yield if request.patch? || request.post?
    end

    def when_delete
      return yield if request.delete?
    end

    def when_get
      return yield if request.get?
    end

    def journey_params
      @journey_params ||= FormJourney::Parameters.new(params, journey_session)
    end

    private

    def previous_steps
      Array(steps.clone).tap do |steps|
        steps.slice!(current_step_index + 1, steps.length)
      end
    end

    def current_step_index
      steps.index(current_step)
    end

    def before_step_action
      method = "before_#{current_step}"
      return self.send(method) if self.respond_to?(method, true)
    end

    def journey_session
      (session["#{params[:controller]}_journey_session".to_sym] ||= {})
    end

    module ClassMethods
      def steps(*steps)
        self._steps.concat(steps)
      end
    end
  end
end
