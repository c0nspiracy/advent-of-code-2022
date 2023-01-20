# frozen_string_literal: true

require "set"

class Tree
  attr_reader :height, :y, :x

  def initialize(height, y, x)
    @height = height
    @y = y
    @x = x
  end

  def to_s
    @height
  end

  def inspect
    "#{height}(#{y},#{x})"
  end
end

class Visibility
  DIRECTIONS = %i[ltr rtl ttb btt].freeze

  def initialize(tree_grid)
    @tree_grid = tree_grid
  end

  def visible_tree_count
    interior_visible_tree_count + edge_visible_tree_count
  end

  def highest_scenic_score
    scenic_scores.max
  end

  private

  def interior_visible_tree_count
    DIRECTIONS.map { |direction| find_interior_visible_trees(direction) }.reduce(:+).size
  end

  def edge_visible_tree_count
    @tree_grid.perimeter_size
  end

  def find_interior_visible_trees(direction)
    @tree_grid.each_interior_row(direction).with_object(Set.new) do |row, memo|
      max = row[0].height
      row[1...-1].each do |tree|
        memo << [tree.y, tree.x] if tree.height > max
        max = [max, tree.height].max
      end
    end
  end

  def scenic_scores
    (1...@tree_grid.max_index).flat_map do |y|
      (1...@tree_grid.max_index).map do |x|
        @tree_grid.count_visible_trees_from(y, x).reduce(:*)
      end
    end
  end
end

class TreeGrid
  def initialize(grid)
    @grid = grid
    @tree_grid = grid.map.with_index do |row, y|
      row.map.with_index do |height, x|
        Tree.new(height, y, x)
      end
    end
  end

  def max_index
    @max_index ||= @grid.size - 1
  end

  def perimeter_size
    max_index * 4
  end

  def each_interior_row(direction = :ltr, &block)
    return enum_for(__method__, direction) { interior_size } unless block_given?

    each_row(direction).drop(1).take(interior_size).each(&block)
  end

  def each_row(direction = :ltr, &block)
    return enum_for(__method__, direction) { @grid.size } unless block_given?

    send("grid_#{direction}").each(&block)
  end

  def count_visible_trees_from(y, x)
    max_height = @grid[y][x]

    directions = [
      (y - 1).step(by: -1, to: 0).to_a.product([x]), # Up
      (y + 1).step(by: 1, to: max_index).to_a.product([x]), # Down
      (x - 1).step(by: -1, to: 0).to_a.product([y]).map(&:reverse), # Left
      (x + 1).step(by: 1, to: max_index).to_a.product([y]).map(&:reverse), # Right
    ]

    directions.map do |coords|
      count = 0

      coords.each do |ny, nx|
        count += 1
        break if @grid[ny][nx] >= max_height
      end
      other_count = 1 + coords.take_while { |ny, nx| @grid[ny][nx] < max_height }.count

      binding.irb unless count == other_count
      count
    end
  end

  private

  def interior_size
    @grid.size - 2
  end

  def grid_ltr
    @tree_grid
  end

  def grid_rtl
    @grid_rtl ||= @tree_grid.map(&:reverse)
  end

  def grid_ttb
    @grid_ttb ||= @tree_grid.transpose
  end

  def grid_btt
    @grid_btt ||= grid_ttb.map(&:reverse)
  end
end

grid = ARGF.readlines(chomp: true).map { _1.chars.map(&:to_i) }
tree_grid = TreeGrid.new(grid)
visibility = Visibility.new(tree_grid)

puts "Part 1: #{visibility.visible_tree_count}"
puts "Part 2: #{visibility.highest_scenic_score}"
