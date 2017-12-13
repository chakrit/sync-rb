# frozen_string_literal: true

require './helpers'

class Balance
  def initialize(amount)
    @amount = Concurrent::Atom.new(amount)
  end

  def amount
    @amount.value
  end

  def credit(delta)
    current = amount
    credit(delta) unless @amount.compare_and_set(current, current + delta)
  end

  def debit(delta)
    current = amount
    debit(delta) unless @amount.compare_and_set(current, current - delta)
  end
end

experiment do
  balance = Balance.new(1000)

  creditor = Thread.new do
    1000.times do
      balance.credit(100)
    end
  end

  debtor = Thread.new do
    1000.times do
      balance.debit(100)
    end
  end

  creditor.join
  debtor.join

  puts "final amount: #{balance.amount}"
end
