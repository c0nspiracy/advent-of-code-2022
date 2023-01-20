# frozen_string_literal: true

pairs = ARGF.readlines(chomp: true).chunk { |l| l.empty? ? :_separator : true }.map(&:last).map { |pair| pair.map { eval(_1) } }

def order(left, right)
  max_size = [left.size, right.size].max

  (0...max_size).each do |i|
    li = left[i]
    ri = right[i]
    return -1 if li.nil?
    return 1 if ri.nil?

    v = case [li, ri]
        in Integer, Integer
          li <=> ri
        else
          order(Array(li), Array(ri))
        end

    return v unless v.zero?
  end

  0
end

part_1 = pairs.each.with_index(1).sum do |(left, right), i|
  order(left, right) == -1 ? i : 0
end
puts "Part 1: #{part_1}"

divider_packets = [[[2]], [[6]]]
pairs << divider_packets
sorted_packets = pairs.flatten(1).sort { |left, right| order(left, right) }
part_2 = divider_packets.map { |packet| sorted_packets.index(packet) + 1 }.reduce(:*)
puts "Part 2: #{part_2}"
