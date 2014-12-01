module FormJourney
  module UsesSingleModel
    extend ActiveSupport::Concern
    included do
      class_attribute :_model_class
      class_attribute :_params_method
    end

    def edit
      journey_params.clear!
      journey_params.set(:_model_object_id, value: params[:id])
      redirect_to step_path(steps.first)
    end

    def editing?
      model_object_id.present?
    end

    def model_object_id
      journey_params.get(:_model_object_id)
    end

    private

    def model_object
      @model_object ||= begin
        if editing?
          self.class._model_class.find(model_object_id).tap do |obj|
            obj.assign_attributes(model_params)
          end
        else
          self.class._model_class.new(model_params)
        end
      end
    end

    def model_params
      if self.class._params_method.respond_to?(:call)
        self.class._params_method.call
      else
        self.send(self.class._params_method.to_sym)
      end
    end

    module ClassMethods
      def params_method(params_method)
        self._params_method = params_method
      end

      def model_class(clasz)
        clasz = clasz.is_a?(String) ? self.const_get(clasz) : clasz
        self._model_class = clasz
        hyphenated_class_name = clasz.to_s.gsub(/::/, '')
          .gsub(/(?<=[^\b])([A-Z])/, '_\1')
          .downcase
        class_eval do
          define_method(hyphenated_class_name.to_sym) do
            model_object
          end
        end
        self.send(:helper_method, hyphenated_class_name.to_sym)
      end
    end
  end
end

