# frozen_string_literal: true

require "matrix"

class Cave
  DISPLAY_EMOJI = { 
    "." => "⬛",
    "#" => "🟫",
    "o" => "🟨",
  }
  def initialize(input, source)
    @cave = Hash.new { |h, k| h[k] = "." }
    @source = source
    initialize_minmax
    parse_input(input)
    @floor = false
  end

  def simulate
    part_1 = 0
    units = 0
    source_path = [Vector[*source]]
    deltas = [Vector[0, 1], Vector[-1, 1], Vector[1, 1]]

    loop do
      break if source_path.empty?

      pos = source_path.last

      loop do
        blocked = true

        deltas.each do |delta|
          new_pos = pos + delta

          if !@floor && new_pos[1] > max_y
            @floor = true
            part_1 = units
          end

          if cave_at(new_pos) == "."
            source_path << new_pos
            pos = new_pos
            blocked = false
            break
          end
        end

        if blocked
          units += 1
          @cave[pos.to_a] = "o"
          source_path.pop
          break
        end
      end
    end

    [part_1, units]
  end

  def display
    @x_width ||= [min_x-5, max_x+5].map { _1.to_s.length }.max
    @y_width ||= [min_y, max_y + 2].map { _1.to_s.length }.max
    @x_coords ||= (min_x..max_x).map do |n|
      if [min_x, max_x, source[0]].include?(n)
        n.to_s.rjust(@x_width).chars
      else
        Array.new(@x_width, " ")
      end
    end.transpose.map do |row|
      row.join.rjust(max_x - min_x + @y_width + 2)
    end

    # @disp_lines ||= @x_coords.size + (max_y - min_y) + 3
    # print "\033[#{@disp_lines}A"
    # print "\r"
    puts

    # @x_coords.each do |xc|
    #   puts xc
    # end

    (min_y..max_y).each do |y|
      line = ((min_x-5)..(max_x+5)).map { |x| DISPLAY_EMOJI[cave_at([x, y])] }.join
      puts "#{y.to_s.rjust(@y_width)} #{line}"
    end
    line = ((min_x-5)..(max_x+5)).map { |x| DISPLAY_EMOJI[cave_at([x, max_y + 1])] }.join
    puts "#{(max_y + 1).to_s.rjust(@y_width)} #{line}"
    line = ((min_x-5)..(max_x+5)).map { DISPLAY_EMOJI["#"] }.join
    puts "#{(max_y + 2).to_s.rjust(@y_width)} #{line}"
    nil
  end

  private

  attr_reader :cave, :source, :min_x, :max_x, :min_y, :max_y

  def cave_at(coord)
    if @floor && coord[1] >= @max_y + 2
      "#"
    else
      cave[coord.to_a]
    end
  end

  def initialize_minmax
    @min_x, @min_y = @source
    @max_x, @max_y = @source
  end

  def parse_input(input)
    paths = []
    input.each do |line|
      coords = line.split(" -> ").map { |c| c.split(",").map(&:to_i) }
      coords.each_cons(2) do |start, finish|
        paths << [start, finish]
      end
    end

    paths.each do |(sx, sy), (fx, fy)|
      @min_x = [min_x, sx, fx].min
      @max_x = [max_x, sx, fx].max
      @max_y = [max_y, sy, fy].max

      if sx == fx
        Range.new(*[sy, fy].sort).each do |py|
          @cave[[sx, py]] = "#"
        end
      else
        Range.new(*[sx, fx].sort).each do |px|
          @cave[[px, sy]] = "#"
        end
      end
    end
  end
end

input = ARGF.readlines(chomp: true)
source = [500, 0]

cave = Cave.new(input, source)
#cave.display
part_1, part_2 = cave.simulate
puts "Part 1: #{part_1}"
puts "Part 2: #{part_2}"
