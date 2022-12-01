# frozen_string_literal: true

input = ARGF.readlines(chomp: true)
elves = input.chunk_while { |_, j| !j.empty? }.map { |food| food.map(&:to_i).sum }

puts "Part 1: #{elves.max}"
puts "Part 2: #{elves.max(3).sum}"
