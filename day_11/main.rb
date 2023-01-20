# frozen_string_literal: true

input = ARGF.readlines(chomp: true)
monkey_inputs = input.chunk { |i| i.empty? ? :_separator : true }.map(&:last)

monkeys = {}
divisor = 1
monkey_inputs.each do |monkey_input|
  id = monkey_input[0].scan(/\d+/).first.to_i
  starting_items = monkey_input[1].scan(/\d+/).map(&:to_i)
  operation = monkey_input[2].scan(/new = old ([+*]) (\w+)/).first
  test = monkey_input[3].scan(/\d+/).first.to_i
  if_true = monkey_input[4].scan(/\d+/).first.to_i
  if_false = monkey_input[5].scan(/\d+/).first.to_i

  if operation[1] == "old"
    op_proc = ->(old) { old * old }
  else
    amount = operation[1].to_i
    if operation[0] == "+"
      op_proc = ->(old) { old + amount }
    else
      op_proc = ->(old) { old * amount }
    end
  end

  monkeys[id] = { 
    starting_items: starting_items,
    operation: op_proc,
    test: test,
    if_true: if_true,
    if_false: if_false,
  }

  divisor *= test
end

def monkey_business(monkeys, rounds, divisor = nil)
  inspections = Hash.new(0)

  monkeys.each { |_, monkey| monkey[:items] = monkey[:starting_items].dup }

  rounds.times do
    monkeys.each do |id, monkey|
      loop do
        break if monkey[:items].empty?
        item = monkey[:items].shift

        inspections[id] += 1
        item = monkey[:operation].call(item)

        if divisor
          item %= divisor
        else
          item /= 3
        end

        if (item % monkey[:test]).zero?
          monkeys[monkey[:if_true]][:items] << item
        else
          monkeys[monkey[:if_false]][:items] << item
        end
      end
    end
  end

  inspections.values.max(2).reduce(:*)
end

part_1 = monkey_business(monkeys, 20)
puts "Part 1: #{part_1}"

part_2 = monkey_business(monkeys, 10_000, divisor)
puts "Part 2: #{part_2}"
