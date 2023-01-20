# frozen_string_literal: true

require "set"

class RopeBridge
  DELTA = {
    "R"  => [ 0,  1],
    "L"  => [ 0, -1],
    "U"  => [ 1,  0],
    "D"  => [-1,  0],
  }

  OPPOSING_DELTA = {
    [-1,  0] => [ 1,  0],
    [-1,  1] => [ 1, -1],
    [ 1, -1] => [-1,  1],
    [ 1,  0] => [-1,  0],
    [ 1,  1] => [-1, -1],
    [-1, -1] => [ 1,  1],
    [ 0, -1] => [ 0,  1],
    [ 0,  1] => [ 0, -1]
  }

  def initialize(motions, debug: false)
    @motions = motions
    @debug = debug
  end

  def simulate(ropes)
    @ropes = Array.new(ropes) { [0, 0] }
    visited = Set.new([[0, 0]])

    puts "== Initial State ==\n\n" if @debug
    display

    @motions.each do |direction, magnitude|
      puts "== #{direction} #{magnitude} ==\n\n" if @debug

      magnitude.to_i.times do |n|
        @ropes[0] = @ropes[0].zip(DELTA[direction]).map(&:sum)

        (1...@ropes.size).each do |i|
          head, tail = @ropes[i - 1, 2]
          next if head == tail

          dy, dx = head.zip(tail).map { _2 - _1 }
          distance = [dy, dx].map(&:abs).sum
          next if distance < 2

          diagonally_adjacent = [dy, dx].one?(&:zero?)
          next if distance == 2 && !diagonally_adjacent

          delta = [dy, dx].map { _1 <=> 0 }
          @ropes[i] = tail.zip(OPPOSING_DELTA[delta]).map(&:sum)
        end

        visited << @ropes.last
      end

      display
    end

    visited.size
  end

  private

  def display(y_range = (0...5), x_range = (0...6))
    return unless @debug

    y_range.reverse_each do |y|
      obscured = []

      line = x_range.map do |x|
        here = []
        here << "s" if y.zero? && x.zero?

        @ropes.each_with_index.reverse_each do |(ry, rx), i|
          next unless ry == y && rx == x

          if i.zero?
            here << "H"
          elsif @ropes.length == 2 && i == 1
            here << "T"
          else
            here << i
          end
        end

        show = here.pop || "."
        obscured << "#{show} covers #{here.reverse.join(", ")}" unless here.empty?
        show
      end

      if obscured.empty?
        puts line.join
      else
        puts "#{line.join}  (#{obscured.join("; ")})"
      end
    end

    puts
  end
end

motions = ARGF.readlines(chomp: true).map(&:split)
debug = ENV.fetch("DEBUG", false)

rope_bridge = RopeBridge.new(motions, debug: debug)

puts "Part 1: #{rope_bridge.simulate(2)}"

if debug
  puts "-- press any key to continue --"
  gets
end

puts "Part 2: #{rope_bridge.simulate(10)}"
