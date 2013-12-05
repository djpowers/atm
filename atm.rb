require 'csv'
require 'yaml'
require 'time'
require 'pry'

class ATM

end

class Account
  attr_reader :first_name, :last_name

  def initialize(first, last, pin, deposit)
    @first_name = first
    @last_name = last
    @pin_number = pin
    @file_path = "#{@pin_number}.csv"
    create_csv
    add_transaction(Deposit.new(deposit))
  end

  def create_csv
    CSV.open(@file_path, 'w') do |csv|
      csv << ["time","transaction type","amount"]
    end
  end

  def add_transaction(transaction)
    if transaction.class == Withdrawal && transaction.amount > balance
      puts 'You have insufficient funds.'
      # return to ATM menu, loop
    else
      CSV.open(@file_path, 'a') do |csv|
        csv << [transaction.date_time, transaction.class, transaction.amount]
      end
    end
  end

  def balance
    balance = 0
    CSV.foreach(@file_path, headers: true) do |transaction|
      balance += transaction["amount"].to_f if transaction["transaction type"] == "Deposit"
      balance -= transaction["amount"].to_f if transaction["transaction type"] == "Withdrawal"
    end
    balance
  end

  def credit_or_debit(transaction)
    transaction["transaction type"] == "Withdrawal" ? "-" : "+"
  end

  def history
    puts "Date & Time / Amount"
    CSV.foreach(@file_path, headers: true) do |transaction|
      puts "#{transaction["time"][0..-7]} / #{credit_or_debit(transaction)}$#{("%.2f" % transaction["amount"])}"
    end
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

class Withdrawal < Transaction
  def initialize(amount)
    super
    @amount = amount.to_f
  end
end


mo_account = Account.new("Mo","Zhu","1234",1000)
5.times do
  mo_account.add_transaction(Deposit.new(100))
  mo_account.add_transaction(Withdrawal.new(50))
end

puts mo_account.balance
mo_account.history
