require 'csv'
require 'yaml'
require 'time'
require 'pry'

class ATM

  def initialize
    @accounts = [Account.new("dave","powers","1234",100),Account.new("mo","zhu","4321",200)]
    @current_account = nil
    #load accounts from YAML into @@accounts
    puts 'Welcome to the ATM.'
  end

  def menu
    puts 'Main Menu:'
    puts 'Enter 1 to login'
    puts 'Enter 2 to create a new account'
    input = gets.chomp.to_i
    if input == 1
      login
    elsif input == 2
      create_account
    else
      puts 'Invalid selection'
      menu
    end
  end

  def login
    puts 'Please enter your PIN:'
    pin_first = gets.chomp
    if pin_exists?(pin_first)
      puts 'Please confirm your PIN:'
      pin_second = gets.chomp
      if pin_first == pin_second
        account_menu
      else
        puts 'That PIN does not match.'
        menu
      end
    else
      puts 'That PIN does not exist.'
      menu
    end
  end

  def create_account
    pin = get_pin
    first = get_first_name
    last = get_last_name
    deposit = get_deposit_amount
    @current_account = Account.new(first, last, pin, deposit)
    @@accounts << @current_account
  end

  def get_pin
    puts 'Enter a PIN:'
    pin = gets.chomp
    if pin_exists?(pin)
      puts 'That PIN already exists.'
      get_pin
    else
      pin
    end
  end

  def get_first_name
    puts 'Please enter your first name:'
    gets.chomp
  end

  def get_last_name
    puts 'Please enter your last name:'
    gets.chomp
  end

  def get_deposit_amount
    puts 'Please enter your deposit amount:'
    gets.chomp.to_i
    # validate number?
  end

  def pin_exists?(pin)
    @accounts.map { |account| account.pin }.include?(pin)
  end

  def account_menu
    puts "Account Menu placeholder"
  end

end

class Account
  attr_reader :first_name, :last_name, :pin

  def initialize(first, last, pin, deposit)
    @first_name = first
    @last_name = last
    @pin = pin
    @file_path = "#{@pin}.csv"
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


ATM.new.menu
