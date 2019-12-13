# frozen_string_literal: true

class OfzEvaluator # :nodoc:
  TAX_DEDUCTION_PERCENT = 13

  def self.call(data)
    new(**data).process
  end

  attr_reader :deposit_days, :deposit_rate, :obligation_price_buy, :obligation_price_sale, :obligation_nominal, :obligation_cnt

  def initialize(deposit_days:, deposit_rate:, obligation_price_buy:, obligation_price_sale:, obligation_nominal:, obligation_cnt:)
    @deposit_days = deposit_days.to_i
    @deposit_rate = deposit_rate.to_d
    @obligation_price_buy = obligation_price_buy.to_d
    @obligation_price_sale = obligation_price_sale.to_d
    @obligation_nominal = obligation_nominal.to_d
    @obligation_cnt = obligation_cnt.to_i
  end

  def process
    deposit_money_per_day * deposit_days + tax_deduction + sale_diff
  end

  private

  def deposit_money_per_day
    return @deposit_money_per_day if @deposit_money_per_day

    deposit_money_per_one_obligation = (deposit_rate * obligation_nominal) / 100
    @deposit_money_per_day = deposit_money_per_one_obligation / 365 * obligation_cnt
  end

  def tax_deduction
    @tax_deduction ||= (TAX_DEDUCTION_PERCENT * obligation_cnt * obligation_price_buy) / 100
  end

  def sale_diff
    @sale_diff ||= (obligation_price_sale - obligation_price_buy) * obligation_cnt
  end
end
