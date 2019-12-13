# frozen_string_literal: true

class ApplicationContainer # :nodoc:
  extend Dry::Container::Mixin
  Import = Dry::AutoInject(self)

  register 'redis', memoize: true do
    Redis.new # TODO: fix with config for production/staging
  end
end
