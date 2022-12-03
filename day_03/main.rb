# frozen_string_literal: true

def priority(item_type)
  case item_type
  in "a".."z" then item_type.ord - 96
  in "A".."Z" then item_type.ord - 38
  end
end

input = ARGF.readlines(chomp: true).map(&:chars)
part_1 = input.flat_map { _1.each_slice(_1.length / 2).reduce(:&) }.sum { priority(_1) }
part_2 = input.each_slice(3).flat_map { _1.reduce(:&) }.sum { priority(_1) }

puts "Part 1: #{part_1}"
puts "Part 1: #{part_2}"
