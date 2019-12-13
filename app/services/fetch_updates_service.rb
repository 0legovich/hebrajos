# frozen_string_literal: true

class FetchUpdatesService # :nodoc:
  BOT_GET_UPDATES_URL = "https://api.telegram.org/bot#{Rails.application.credentials.tg_bot[:token]}/getUpdates"
  LONG_POOLING_TIMEOUT = 50 # seconds

  def self.call
    new.process
  end

  def process
    result =
      begin
        new_client.get
      rescue Faraday::Error => e
        return Dry::Monads::Failure(e.to_s)
      end

    return Dry::Monads::Failure('Tg http response status invalid') unless (200..202).include?(result.status)

    parsed_result = parse(result)
    return Dry::Monads::Failure('Tg bot get invalid data') unless parsed_result[:ok]

    Dry::Monads::Success(
      parsed_result[:result].sort_by { |i| i[:update_id] }
    )
  end

  def new_client
    url = BOT_GET_UPDATES_URL + "?timeout=#{LONG_POOLING_TIMEOUT}&offset=#{offset}"
    Faraday.new(url, ssl: { verify: false }) do |conn|
      conn.request :url_encoded
      conn.adapter :net_http
    end
  end

  def parse(response)
    JSON.parse(response.body).with_indifferent_access
  end

  def offset
    LastUpdate.get + 1
  end
end
