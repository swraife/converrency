require 'spec_helper'

describe Converrency::Money do
  let(:money) { described_class.new(amount, currency) }
  let(:amount) { 50 }
  let(:currency) { 'EUR' }
  let(:base_currency) { 'EUR' }
  let(:currencies) { { 'USD' => 1.11,
                       'Bitcoin' => 0.0047 } }

  describe '.currency_rates' do
    it 'sets a the conversion rates relative to base currency' do
      described_class.currency_rates(base_currency, currencies)
      expect(described_class.base_currency).to eq('EUR')
      expect(
        described_class.currencies
      ).to eq(currencies.merge(base_currency => 1))
    end
  end

  context 'when currency_rates have been set' do
    before(:each) do
      described_class.currency_rates(base_currency, currencies)
    end

    describe '#new' do
      it 'accepts an amount and currency argument' do
        expect(
          described_class.new(amount, currency).class
        ).to eq(Converrency::Money)
      end

      it 'throws an error if given an invalid currency' do
        expect do
          described_class.new(amount, 'FAKE')
        end.to raise_error ArgumentError
      end
    end

    describe '#amount' do
      it 'returns the amount of money' do
        expect(money.amount).to eq(amount)
      end
    end

    describe '#currency' do
      it 'returns the currency of money' do
        expect(money.currency).to eq(currency)
      end
    end

    describe '#inspect' do
      it 'returns a string with the amount and currency' do
        expect(money.inspect).to eq('50.00 EUR')
      end
    end

    describe '#convert_to' do
      it 'returns a new money object' do
        expect(money.convert_to('USD').class).to eq(Converrency::Money)
      end

      context 'when converting from the base currency' do
        it 'converts to another currency' do
          expect(money.convert_to('USD').inspect).to eq('55.50 USD')
        end

        it 'converts to the base_currency' do
          expect(money.convert_to('EUR').inspect).to eq('50.00 EUR')
        end
      end

      context 'when converting from a non-base currency' do
        let(:currency) { 'USD' }

        it 'converts to the base' do
          expect(money.convert_to('EUR').inspect).to eq('45.05 EUR')
        end

        it 'converts to another non-base currency' do
          expect(money.convert_to('Bitcoin').inspect).to eq('0.21 Bitcoin')
        end
      end
    end

    describe '+' do
      it 'correctly sums when given the same currencies' do
        result = money + described_class.new(20, 'EUR')
        expect(result.inspect).to eq('70.00 EUR')
      end

      it 'correctly sums when given two different currencies' do
        result = money + described_class.new(11.1, 'USD')
        expect(result.inspect).to eq('60.00 EUR')
      end
    end

    describe '-' do
      it 'correctly subtracts when given the same currencies' do
        result = money - described_class.new(20, 'EUR')
        expect(result.inspect).to eq('30.00 EUR')
      end

      it 'correctly subtracts when given two different currencies' do
        result = money - described_class.new(11.1, 'USD')
        expect(result.inspect).to eq('40.00 EUR')
      end
    end

    describe '*' do
      it 'correctly multiplies when given the same currencies' do
        result = money * described_class.new(20, 'EUR')
        expect(result.inspect).to eq('1000.00 EUR')
      end

      it 'correctly multiplies when given two different currencies' do
        result = money * described_class.new(11.1, 'USD')
        expect(result.inspect).to eq('500.00 EUR')
      end
    end

    describe '/' do
      it 'correctly divides when given the same currencies' do
        result = money / described_class.new(20, 'EUR')
        expect(result.inspect).to eq('2.50 EUR')
      end

      it 'correctly divides when given two different currencies' do
        result = money / described_class.new(11.1, 'USD')
        expect(result.inspect).to eq('5.00 EUR')
      end
    end

    describe '==' do
      context 'when the currency type is the same' do
        it 'returns true when the amounts equal to two decimals' do
          expect(money == described_class.new(50.003, 'EUR')).to be true
        end

        it 'returns false when the amounts are not equal' do
          expect(money == described_class.new(45, 'EUR')).to be false
        end
      end

      context 'when the currency type is the different' do
        it 'returns true when the converted amounts equal to two decimals' do
          expect(money == described_class.new(55.50, 'USD')).to be true
        end

        it 'returns false when the amounts are not equal' do
          expect(money == described_class.new(57, 'USD')).to be false
        end
      end
    end

    describe '>' do
      context 'when the currency type is the same' do
        it 'returns true when greater than other value' do
          expect(money > described_class.new(45, 'EUR')).to be true
        end

        it 'returns false when equal or less than other value' do
          expect(money > described_class.new(50.003, 'EUR')).to be false
        end
      end

      context 'when the currency type is the different' do
        it 'returns true when greater than other value' do
          expect(money > described_class.new(53.50, 'USD')).to be true
        end

        it 'returns false when equal or less than other value' do
          expect(money > described_class.new(70, 'USD')).to be false
        end
      end
    end
  end
end
