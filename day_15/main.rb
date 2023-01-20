# frozen_string_literal: true

require "set"
require "matrix"

class Range
  def overlaps?(other)
    other.begin == self.begin || cover?(other.begin) || other.cover?(self.begin)
  end
end

def join_ranges(ranges)
  #puts "Starting with: #{ranges}"
  ranges = ranges.to_a.sort_by(&:begin).uniq
  return ranges if ranges.size == 1

  #puts "After sort & uniq: #{ranges}"
  ranges.reject! { |range| (ranges - [range]).any? { |other_range| other_range.cover?(range) } }
  #puts "After removing fully overlapping: #{ranges}"

  outer_i = 1
  loop do
    break if ranges.each_cons(2).none? { |left, right| left.overlaps?(right) }

    new_ranges = []
    left = ranges.shift
    right = ranges.shift

    #inner_i = 1
    loop do
      break if left.nil? || right.nil?

      if left.overlaps?(right) || (left.end + 1 == right.begin)
        new_range = Range.new([left.begin, right.begin].min, [left.end, right.end].max)
        new_ranges << new_range
        left = ranges.shift
        right = ranges.shift
      else
        new_ranges << left
        left = right
        right = ranges.shift
      end

      #puts "After inner loop #{inner_i}: new ranges: #{new_ranges}, left: #{left}, right: #{right}"
      #inner_i += 1
    end

    new_ranges << left if left
    new_ranges << right if right
    ranges = new_ranges
    #puts "After outer loop #{outer_i}: #{ranges}"
    #outer_i += 1
  end

  ranges
end

if ARGV.first == "example"
  target_y = 10
  search_space = (0..20)
else
  target_y = 2_000_000
  search_space = (0..4_000_000)
end

beacons_along_target = Set.new
no_beacon_ranges = Set.new
search_results = Hash.new { |h, k| h[k] = Set.new }

input = ARGF.readlines(chomp: true)
ln = 0
input.each do |line|
  ln += 1
  sensor_x, sensor_y, bx, by = line.scan(/-?\d+/).map(&:to_i)

  sensor = Vector[sensor_x, sensor_y]
  beacon = Vector[bx, by]
  beacons_along_target << bx if by == target_y

  manhattan_distance = (sensor - beacon).map(&:abs).sum
  sensor_range = (sensor_y - manhattan_distance)..(sensor_y + manhattan_distance)

  if sensor_range.cover?(search_space)
    overlapping_range = sensor_range
  elsif sensor_range.overlaps?(search_space)
    overlapping_range = Range.new(
      [search_space.begin, sensor_range.begin].max,
      [search_space.end, sensor_range.end].min
    )
  end
  next unless overlapping_range

  puts "processing line #{ln} of #{input.size}"
  overlapping_range.each do |y|
    if search_results[y].size == 1 && search_results[y][0] == search_space
      next
    end

    #puts "processing #{y} of #{overlapping_range.end}, on line #{ln} of #{input.size}"

    radius = manhattan_distance - (y - sensor_y).abs
    diameter = radius * 2
    start_x = sensor_x - radius
    end_x = start_x + diameter
    no_beacon_ranges << (start_x..end_x) if y == target_y

    range = Range.new([start_x, search_space.begin].max, [end_x, search_space.end].min)
    search_results[y] << range
    search_results[y] = join_ranges(search_results[y])
  end
end


joined_ranges = join_ranges(no_beacon_ranges)
part_1 = joined_ranges.sum(&:size) - beacons_along_target.size

puts "Part 1: #{part_1}"

#search_results.transform_values! { |ranges| join_ranges(ranges) }
y, xs = search_results.detect { !_2.one? }
x = xs[0].end + 1
part_2 = (x * 4_000_000) + y
puts "Only position that could have a beacon: x=#{x}, y=#{y}"
puts "Part 2: #{part_2}"
