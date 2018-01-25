module Converrency
  class Money

    attr_reader :currency, :amount

    class << self
      attr_reader :base_currency, :currencies

      def currency_rates(base_currency, currencies)
        @base_currency = base_currency
        @currencies = currencies.merge(base_currency => 1.0)
      end

      def valid_currency?(currency)
        base_currency == currency || currencies.has_key?(currency)
      end
    end

    def initialize(amount, currency)
      unless self.class.valid_currency?(currency)
        raise ArgumentError.new('Invalid currency')
      end

      @amount = amount
      @currency = currency
    end

    def inspect
      "#{print_amount} #{currency}"
    end

    def convert_to(new_currency)
      converted_amount = value_in_base_currency * currencies[new_currency]
      Money.new(converted_amount, new_currency)
    end

    [:+, :-, :*, :/].each do |meth|
      define_method(meth) do |money|
        new_amount = amount.send(meth, money.convert_to(currency).amount)
        Money.new(new_amount, currency)
      end
    end

    [:==, :<, :>, :<=, :>=].each do |meth|
      define_method(meth) do |money|
        amount.round(2).send(meth, money.convert_to(currency).amount.round(2))
      end
    end

    private

    def print_amount
      "%.2f" % amount.round(2)      
    end

    def value_in_base_currency
      amount / currencies[currency]
    end

    def base_currency
      self.class.base_currency
    end

    def currencies
      self.class.currencies
    end
  end
end
