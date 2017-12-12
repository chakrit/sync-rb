# frozen_string_literal: true

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

def experiment
  balance = Balance.new(1000)

  omise = Thread.new do
    1000.times do
      balance.credit(100)
    end
  end

  employee = Thread.new do
    1000.times do
      balance.debit(100)
    end
  end

  omise.join
  employee.join
  puts "final amount: #{balance.amount}"
end

20.times do
  experiment
end
