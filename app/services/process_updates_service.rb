# frozen_string_literal: true

class ProcessUpdatesService # :nodoc:
  def self.call(updates)
    new(updates).process
  end

  attr_reader :updates

  def initialize(updates)
    @updates = updates
  end

  def process
    return false if updates.blank?

    updates.each do |node|
      message = node[:message]
      next if message.blank?

      new_message(node) if message[:text].present?
    end
    refresh_last_update_id(updates.last[:update_id])
    true
  end

  private

  def new_message(node)
    return if node.dig(:message, :chat, :type) != 'private'

    parsed_result = ParseOfzData.call(node.dig(:message, :text))
    return SendMessage.call(parsed_result.failure, node.dig(:message, :from, :id)) if parsed_result.failure?

    calculated_value = OfzEvaluator.call(parsed_result.value!)
    SendMessage.call("Твой доход: #{calculated_value.to_f.round(2)}", node.dig(:message, :from, :id))
  end

  def refresh_last_update_id(id)
    LastUpdate.set(id)
  end
end
