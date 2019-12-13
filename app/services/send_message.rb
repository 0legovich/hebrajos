# frozen_string_literal: true

class SendMessage # :nodoc:
  BOT_SEND_MESSAGE_URL = "https://api.telegram.org/bot#{Rails.application.credentials.tg_bot[:token]}/sendMessage"

  def self.call(text, chat_id)
    return if text.blank? || chat_id.blank?

    new(text, chat_id).process
  end

  attr_reader :body

  def initialize(text, chat_id)
    @body = { text: text, chat_id: chat_id }.to_json
  end

  def process
    response = post_message
    return false if response.nil?
    return true if response.status == 200

    false
  end

  private

  def post_message
    client = Faraday.new(BOT_SEND_MESSAGE_URL, ssl: { verify: false }) do |conn|
      conn.request :url_encoded
      conn.adapter :net_http
    end
    response = client.post do |req|
      req['Content-Type'] = 'application/json'
      req.body = body
    end

    response
  rescue Faraday::Error
    nil
  end
end
