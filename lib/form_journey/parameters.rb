module FormJourney
  class Parameters < HashWithIndifferentAccess
    def initialize(attributes = nil, session)
      @session = (session || {})
      @session.deep_merge!(attributes.deep_symbolize_keys) if attributes
      super(@session)
    end

    def clear!
      replace({})
      @session.clear
    end

    def []=(key, value)
      super
      update_session
    end

    def get(*keys)
      params = to_hash
      while !keys.empty?
        return nil if params.nil?
        params = params[keys.shift.to_s]
      end
      params
    end

    def del(*keys)
      parent_param = self
      while !keys.empty?
        return nil if parent_param.nil?

        if keys.length == 1
          del_param = parent_param.try(:delete, keys.shift)
          update_session
          return del_param
        end
        parent_param = parent_param[keys.shift]
      end
    end

    def set(*keys, value:)
      parent_param = self
      while !keys.empty?
        return nil if parent_param.nil?

        if keys.length == 1
          parent_param[keys.shift] = value
          update_session
          return self
        end
        parent_param = parent_param[keys.shift]
      end
    end

    def add_to_array(*path, value:, unique: false)
      array = Array(get(*path))
      array << value
      array.uniq! if unique
      set(*path, value: array)
    end

    def remove_from_array(*path, value:)
      array = Array(get(*path))
      array.select! { |v| v != value }
      set(*path, value: array)
    end

    def require(key)
      ActionController::Parameters.new(to_hash).require(key)
    end

    private

    def update_session
      @session.clear
      @session.merge!(deep_symbolize_keys)
    end
  end
end
