module FormJourney
  module Parameters
    extend ActiveSupport::Concern

    included do
      before_action :update_journey_params
      helper_method :journey_params
      helper_method :get_journey_param
    end

    def journey_params
      session[:journey_params] ||= {}
    end

    def clear_journey_params
      session[:journey_params] = {}
    end

    def get_journey_param(*keys)
      params = journey_params.clone.deep_stringify_keys
      while !keys.empty?
        return nil if params.nil?
        params = params[keys.shift.to_s]
      end
      params
    end

    def del_journey_param(*keys)
      parent_param = journey_params
      while !keys.empty?
        return nil if parent_param.nil?

        if keys.length == 1
          del_param = parent_param.try(:delete, keys.shift.to_s)
          return del_param
        end
        parent_param = parent_param[keys.shift.to_s]
      end
    end

    private

    def update_journey_params
      journey_params.deep_merge!(filtered_params)
    end

    def filtered_params
      params.deep_stringify_keys.reject do |k, value|
        ['utf8', 'authenticity_token'].include?(k) || value.blank?
      end
    end
  end
end
