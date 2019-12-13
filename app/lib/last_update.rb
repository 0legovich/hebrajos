# frozen_string_literal: true

module LastUpdate # :nodoc:
  REDIS_KEY = 'hebrajos_last_update'

  module_function

  def get
    ApplicationContainer.resolve(:redis).get(REDIS_KEY).to_i || 0
  end

  def set(value)
    ApplicationContainer.resolve(:redis).set(REDIS_KEY, value)
  end
end
