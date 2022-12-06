# frozen_string_literal: true

signal = ARGF.read.chomp

def find_end_of_marker(signal, marker_length)
  _, start = signal.chars.each_cons(marker_length).with_index.find do |marker, _|
    marker.uniq.count == marker_length
  end
  start + marker_length
end

puts "Part 1: #{find_end_of_marker(signal, 4)}"
puts "Part 2: #{find_end_of_marker(signal, 14)}"
