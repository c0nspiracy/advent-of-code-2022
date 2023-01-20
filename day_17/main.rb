# frozen_string_literal: true

PART_1_ITERATIONS = 2_022
PART_2_ITERATIONS = 1_000_000_000_000

class Rock
  attr_reader :shape

  def initialize(shape)
    @shape = shape
  end

  def height
    @height ||= @shape.size
  end

  def width
    @width ||= @shape[0].size
  end

  def to_grid(x, y)
    grid = Hash.new

    shape.each_with_index do |line, sy|
      line.chars.each_with_index do |char, sx|
        grid[[y - sy, x + sx]] = "#" if char == "#"
      end
    end

    grid
  end
end

ROCKS = [
  [
    "####"
  ],
  [
    ".#.",
    "###",
    ".#.",
  ],
  [
    "..#",
    "..#",
    "###",
  ],
  [
    "#",
    "#",
    "#",
    "#",
  ],
  [
    "##",
    "##",
  ]
].map { |shape| Rock.new(shape) }

input = ARGF.read.chomp.chars

rocks = ROCKS.cycle
gas = input.cycle
floor = 0
grid = {}
spawn_y = 0
$debug = false

def display(grid, height, rock, ry, rx, bottom = 0)
  return unless $debug

  shape_grid = rock.to_grid(rx, ry) if rock
  height.downto(bottom) do |y|
    row = (0...7).map do |x|
      if grid.key?([y, x])
        "#"
      elsif rock && shape_grid.key?([y, x])
        "@"
      else
        "."
      end
    end
    puts "|#{row.join}|"
  end
  puts "+-------+"
end

def debug(msg)
  puts msg if $debug
end

iteration = 0
part_1 = 0
part_2 = nil
part_2_remainder = 0
capture_part_2_remainder = false
highest_y = 0
patterns = {}

loop do
  iteration += 1
  if capture_part_2_remainder
    puts "Capturing part 2 remainder: #{part_2_remainder}" if part_2_remainder > 0
    part_2_remainder -= 1 
    break if !part_2.nil? && part_2_remainder < 0
  end

  puts if $debug
  if iteration == 0
    debug "The first rock begins falling:"
  else
    debug "A new rock begins falling:"
  end
  current_rock = rocks.next
  rock_h = current_rock.height
  rock_w = current_rock.width
  rock_y = spawn_y + 3 + rock_h - 1
  rock_x = 2
  display(grid, rock_y, current_rock, rock_y, rock_x)

  loop do
    #############
    #### JET ####
    #############
    jet = gas.next
    case jet
    when "<"
      if rock_x > 0
        shape_grid = current_rock.to_grid(rock_x - 1, rock_y)
        if shape_grid.keys.any? { |pos| grid[pos] == "#" }
          debug "Jet of gas pushes rock left, but nothing happens:"
        else
          debug "Jet of gas pushes rock left:"
          rock_x -= 1
        end
      else
        debug "Jet of gas pushes rock left, but nothing happens:"
      end
    when ">"
      if rock_x < (7 - rock_w)
        shape_grid = current_rock.to_grid(rock_x + 1, rock_y)
        if shape_grid.keys.any? { |pos| grid[pos] == "#" }
          debug "Jet of gas pushes rock right, but nothing happens:"
        else
          debug "Jet of gas pushes rock right:"
          rock_x += 1
        end
      else
        debug "Jet of gas pushes rock right, but nothing happens:"
      end
    end
    display(grid, rock_y, current_rock, rock_y, rock_x)

    ##############
    #### FALL ####
    ##############
    shape_grid = current_rock.to_grid(rock_x, rock_y - 1)
    if (rock_y - (rock_h - 1)) == floor || shape_grid.keys.any? { |pos| grid[pos] == "#" }
      debug "Rock falls 1 unit, causing it to come to rest:"
      break
    else
      rock_y -= 1
      debug "Rock falls 1 unit:"
      display(grid, rock_y, current_rock, rock_y, rock_x)
    end
  end

  grid.merge!(current_rock.to_grid(rock_x, rock_y))
  diff = 0
  if rock_y > highest_y
    diff = rock_y - highest_y
    part_2 += diff if capture_part_2_remainder && part_2_remainder >= 0
    highest_y = rock_y
  end

  spawn_y = highest_y + 1

  display(grid, spawn_y, nil, rock_y, rock_x)
  part_1 = spawn_y if iteration == PART_1_ITERATIONS

  if part_2.nil? && iteration > PART_1_ITERATIONS
    ys_to_check = (rock_y..(rock_y + rock_h - 1))
    ys_to_check.each do |sy|
      if (0...6).all? { |x| grid.key?([sy, x]) }
      #if (0...6).map { |x| grid[[sy, x]] }.all? { |c| c == "#" }
        pattern = ((sy-5)..sy).map do |py|
          (0...7).map do |px|
            grid[[py, px]] ? "#" : "."
          end.join
        end

        puts "Cavern is fully bridged at #{sy}."
        patterns[[iteration, highest_y]] = pattern

        match = patterns.to_a.combination(3).detect { |(_, p1), (_, p2), (_, p3)| p1 == p2 && p2 == p3 }
        if match
          y1, sy1 = match[1][0]
          y2, sy2 = match[2][0]
          rocks_per_cycle = (y2 - y1).abs
          height_per_cycle = (sy2 - sy1).abs
          remaining_rocks = PART_2_ITERATIONS - iteration
          complete_cycles, remainder = remaining_rocks.divmod(rocks_per_cycle)

          full_cycle_height = complete_cycles * height_per_cycle
          part_2 = full_cycle_height + highest_y + diff
          part_2_remainder = remainder + 1
          puts "==== FOUND A PATTERN ===="
          puts "Rocks dropped in each cycle: #{rocks_per_cycle}"
          puts "Height gained in each cycle: #{height_per_cycle}"
          puts "Dropped #{iteration} rocks so far"
          puts "Got #{remaining_rocks} rocks left to go"
          puts "That means another #{complete_cycles} full cycles, plus #{part_2_remainder} additional rocks to reach the full #{PART_2_ITERATIONS}"
        end
        # $debug = true
        # display(grid, spawn_y, nil, 0, 0, sy - 1)
        # $debug = false
        capture_part_2_remainder = true
      end
    end
  end
end
display(grid, spawn_y-1, nil, 0, 0)

puts "Part 1: #{part_1}"
puts "Part 2: #{part_2}"
