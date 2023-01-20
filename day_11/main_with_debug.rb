# frozen_string_literal: true

input = ARGF.readlines(chomp: true)
monkey_inputs = input.chunk { |i| i.empty? ? :_separator : true }.map(&:last)

monkeys = {}
divisors = 1
monkey_inputs.each do |monkey_input|
  id = monkey_input[0].scan(/\d+/).first.to_i
  starting_items = monkey_input[1].scan(/\d+/).map(&:to_i)
  operation = monkey_input[2].scan(/new = old ([+*]) (\w+)/).first
  test = monkey_input[3].scan(/\d+/).first.to_i
  if_true = monkey_input[4].scan(/\d+/).first.to_i
  if_false = monkey_input[5].scan(/\d+/).first.to_i

  monkeys[id] = { 
    items: starting_items,
    operation: operation,
    test: test,
    if_true: if_true,
    if_false: if_false,
  }

  divisors *= test
end

monkey_inspections = Hash.new(0)
round = 1
loop do
  monkeys.each do |id, monkey|
    puts "Monkey #{id}:"

    loop do
      break if monkey[:items].empty?
      item = monkey[:items].shift

      monkey_inspections[id] += 1
      puts "  Monkey inspects an item with a worry level of #{item}."
      op, amount = monkey[:operation]
      amount = amount.to_i if amount.match?(/\d+/)
      if op == "*"
        if amount == "old"
          item *= item
          puts "    Worry level is multiplied by itself to #{item}"
        else
          item *= amount
          puts "    Worry level is multiplied by #{amount} to #{item}"
        end
      elsif op == "+"
        item += amount
        puts "    Worry level increases by #{amount} to #{item}"
      end

      #item /= 3
      item %= divisors
      puts "    Monkey gets bored with item. Worry level is divided by 3 to #{item}."

      if (item % monkey[:test]).zero?
        puts "    Current worry is divisible by #{monkey[:test]}."
        puts "    Item with worry level #{item} is thrown to monkey #{monkey[:if_true]}."
        monkeys[monkey[:if_true]][:items] << item
      else
        puts "    Current worry is not divisible by #{monkey[:test]}."
        puts "    Item with worry level #{item} is thrown to monkey #{monkey[:if_false]}."
        monkeys[monkey[:if_false]][:items] << item
      end
    end
  end

  puts "After round #{round}:"
  monkeys.each do |id, monkey|
    puts "Monkey #{id}: #{monkey[:items].join(', ')}"
  end
  round += 1
  break if round == 10001
end

monkey_inspections.each do |id, count|
  puts "Monkey #{id} inspected items #{count} times."
end

part_1 = monkey_inspections.values.max(2).reduce(:*)
puts "Part 1: #{part_1}"
