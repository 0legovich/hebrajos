# frozen_string_literal: true

class ProcessUpdatesJob < ApplicationJob # :nodoc:
  def perform
    while true
      result = FetchUpdatesService.call
      ProcessUpdatesService.call(result.value!) if result.success?
    end
  end
end
