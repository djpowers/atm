require 'csv'
require 'yaml'

class ATM

end

class Account
  attr_reader :first_name, :last_name

  def initialize(first, last, pin, deposit)
    @first_name = first
    @last_name = last
    @pin_number = pin
    @file_path = "#{@pin_number}.csv"
    CSV.open(@file_path, 'w') << ["time","amount"]
    add_transaction(Deposit.new(deposit))
  end

  def add_transaction(transaction)
    CSV.open(@file_path, 'a')  << [transaction.date_time, transaction.amount]
  end

  def balance
    balance = 0
    @transactions.each do |transaction|
      balance += transaction.amount
    end
    balance
  end

end

class Transaction
  attr_reader :date_time, :amount

  def initialize(amount)
    @date_time = Time.now
  end

end

class Deposit < Transaction
  def initialize(amount)
    super
    @amount = amount.to_f
  end
end

class Withdraw < Transaction
  def initialize(amount)
    super
    @amount = amount.to_f * -1
  end
end


mo_account = Account.new("Mo","Zhu","1234",100)

# 5.times do
  # mo_account.add_transaction(Deposit.new(100))
  # mo_account.add_transaction(Withdraw.new(50))
  # puts mo_account.balance
  # puts mo_account.transactions
# end
