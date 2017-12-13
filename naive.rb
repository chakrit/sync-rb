# frozen_string_literal: true

require './helpers'

class Balance
  attr_accessor :amount

  def initialize(amount)
    @amount = amount
  end

  def credit(delta)
    @amount += delta
  end

  def debit(delta)
    @amount -= delta
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
