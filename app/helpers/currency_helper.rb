module CurrencyHelper
  def currency_selector
    CurrencyController::CURRENCIES.each_with_object([]) do |c, result|
      result << [c, c]
    end
  end
end
