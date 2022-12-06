# frozen_string_literal: true

require "set"

def sections_to_set(sections)
  Range.new(*sections.split("-").map(&:to_i)).to_set
end

input = ARGF.readlines(chomp: true)
pairs = input.map { _1.split(",") }
contain_count = 0
overlap_count = 0

pairs.each do |first, second|
  first_set = sections_to_set(first)
  second_set = sections_to_set(second)
  contain_count += 1 if first_set.subset?(second_set) || second_set.subset?(first_set)
  overlap_count += 1 if first_set.intersect?(second_set)
end

puts "Part 1: #{contain_count}"
puts "Part 2: #{overlap_count}"
