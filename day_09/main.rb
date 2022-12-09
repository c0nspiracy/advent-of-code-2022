# frozen_string_literal: true

require "set"
require "matrix"

class RopeBridge
  DIRECTION = {
    "R" => Vector[ 0,  1],
    "L" => Vector[ 0, -1],
    "U" => Vector[ 1,  0],
    "D" => Vector[-1,  0],
  }.freeze

  def initialize(motions)
    @motions = motions
  end

  def simulate(rope_count)
    ropes = Array.new(rope_count) { Vector.zero(2) }
    visited = Set.new([ropes.last])

    @motions.each do |direction, steps|
      steps.times do
        ropes[0] += DIRECTION[direction]

        (0...ropes.size).each_cons(2) do |head_idx, tail_idx|
          head, tail = ropes.values_at(head_idx, tail_idx)
          next if head == tail

          distance = tail - head
          ropes[tail_idx] += distance.map { 0 <=> _1 } if distance.magnitude >= 2
        end

        visited << ropes.last
      end
    end

    visited.size
  end
end

motions = ARGF.readlines(chomp: true).map(&:split).map { [_1, _2.to_i] }

rope_bridge = RopeBridge.new(motions)
puts "Part 1: #{rope_bridge.simulate(2)}"
puts "Part 2: #{rope_bridge.simulate(10)}"
