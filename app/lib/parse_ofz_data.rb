# frozen_string_literal: true

# Формат:
# Д: deposit_days - дней вклада
# С: deposit_rate - ставка по купону
# К: obligation_price_buy - цена покупки купона
# П: obligation_price_sale - цена продажи купона
# Н: obligation_nominal - номиинал купона
# В: obligation_cnt - колчество покупаемых купонов


class ParseOfzData # :nodoc:
  def self.call(message)
    new(message).process
  end

  attr_reader :message, :items

  def initialize(message)
    @message = message&.chomp || ''
    @items = message&.split("\n") || []
  end

  def process
    return Dry::Monads::Failure('Данные не по формату' + format_text) unless matches_format?
    return Dry::Monads::Failure('По формату, но плохие данные' + format_text) unless result_valid?

    Dry::Monads::Success(result)
  end

  private

  def matches_format?
    return false if items.count != 6

    items[0].start_with?('Д: ') &&
      items[1].start_with?('С: ') &&
      items[2].start_with?('К: ') &&
      items[3].start_with?('П: ') &&
      items[4].start_with?('Н: ') &&
      items[5].start_with?('В: ')
  end

  def result
    @result ||=
      {
        deposit_days: normalize(items[0].gsub('Д: ', '')),
        deposit_rate: normalize(items[1].gsub('С: ', '')),
        obligation_price_buy: normalize(items[2].gsub('К: ', '')),
        obligation_price_sale: normalize(items[3].gsub('П: ', '')),
        obligation_nominal: normalize(items[4].gsub('Н: ', '')),
        obligation_cnt: normalize(items[5].gsub('В: ', ''))
      }
  end

  def normalize(item)
    item.tr(',', '.')
  end

  def result_valid?
    result.values.all?(&:present?)
  end

  def format_text # TODO: refactor
    %(\n
      Д: дней вклада
      С: ставка по купону
      К: цена покупки купона
      П: цена продажи купона
      Н: номинал купона
      В: количество покупаемых купонов

      Например:
      Д: 1095
      С: 7.38
      К: 1061.8
      П: 1000
      Н: 1000
      В: 1
    ).gsub('      ', '')
  end
end
