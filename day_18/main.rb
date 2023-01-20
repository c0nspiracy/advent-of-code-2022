# frozen_string_literal: true

class Cube
  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x = x
    @y = y
    @z = z
  end
end

cube_hash = {}
cubes = ARGF.readlines(chomp: true).map do |line|
  x, y, z = line.split(",").map(&:to_i)
  cube_hash[[x, y, z]] = "+"
  Cube.new(x, y, z)
end

possible_gaps = Hash.new { |h, k| h[k] = 0 }

min_x, max_x = cubes.map(&:x).minmax
(min_x..max_x).each do |x|
  x_cubes = cubes.select { |c| c.x == x }
  next if x_cubes.empty?

  min_y, max_y = x_cubes.map(&:y).minmax
  (min_y..max_y).each do |y|
    y_cubes = x_cubes.select { |c| c.y == y }
    next if y_cubes.empty?

    min_z, max_z = y_cubes.map(&:z).minmax
    (min_z..max_z).each do |z|
      possible_gaps[[x, y, z]] += 1 unless cube_hash.key?([x, y, z])
    end
  end

  min_z, max_z = x_cubes.map(&:z).minmax
  (min_z..max_z).each do |z|
    z_cubes = x_cubes.select { |c| c.z == z }
    next if z_cubes.empty?

    min_y, max_y = z_cubes.map(&:y).minmax
    (min_y..max_y).each do |y|
      possible_gaps[[x, y, z]] += 1 unless cube_hash.key?([x, y, z])
    end
  end
end

min_y, max_y = cubes.map(&:y).minmax
(min_y..max_y).each do |y|
  y_cubes = cubes.select { |c| c.y == y }
  next if y_cubes.empty?

  min_x, max_x = y_cubes.map(&:x).minmax
  (min_x..max_x).each do |x|
    x_cubes = y_cubes.select { |c| c.x == x }
    next if x_cubes.empty?

    min_z, max_z = x_cubes.map(&:z).minmax
    (min_z..max_z).each do |z|
      possible_gaps[[x, y, z]] += 1 unless cube_hash.key?([x, y, z])
    end
  end

  min_z, max_z = y_cubes.map(&:z).minmax
  (min_z..max_z).each do |z|
    z_cubes = y_cubes.select { |c| c.z == z }
    next if z_cubes.empty?

    min_x, max_x = z_cubes.map(&:x).minmax
    (min_x..max_x).each do |x|
      possible_gaps[[x, y, z]] += 1 unless cube_hash.key?([x, y, z])
    end
  end
end

min_z, max_z = cubes.map(&:z).minmax
(min_z..max_z).each do |z|
  z_cubes = cubes.select { |c| c.z == z }
  next if z_cubes.empty?

  min_x, max_x = z_cubes.map(&:x).minmax
  (min_x..max_x).each do |x|
    x_cubes = z_cubes.select { |c| c.x == x }
    next if x_cubes.empty?

    min_y, max_y = x_cubes.map(&:y).minmax
    (min_y..max_y).each do |y|
      possible_gaps[[x, y, z]] += 1 unless cube_hash.key?([x, y, z])
    end
  end

  min_y, max_y = z_cubes.map(&:y).minmax
  (min_y..max_y).each do |y|
    y_cubes = z_cubes.select { |c| c.y == y }
    next if y_cubes.empty?

    min_x, max_x = y_cubes.map(&:x).minmax
    (min_x..max_x).each do |x|
      possible_gaps[[x, y, z]] += 1 unless cube_hash.key?([x, y, z])
    end
  end
end
possible_gaps.reject! { |_, v| v < 6 }
binding.irb

max_faces = cubes.size * 6
neighbours = 0
trapped = {}

cubes.each do |cube|
  this_neighbours = 0

  if cube_hash.key?([cube.x - 1, cube.y, cube.z])
    this_neighbours += 1
  else
    # possible_gaps[[cube.x - 1, cube.y, cube.z]] += 1
  end

  if cube_hash.key?([cube.x + 1, cube.y, cube.z])
    this_neighbours += 1 
  else
    # possible_gaps[[cube.x + 1, cube.y, cube.z]] += 1
  end

  if cube_hash.key?([cube.x, cube.y - 1, cube.z])
    this_neighbours += 1
  else
    # possible_gaps[[cube.x, cube.y - 1, cube.z]] += 1
  end

  if cube_hash.key?([cube.x, cube.y + 1, cube.z])
    this_neighbours += 1 
  else
    # possible_gaps[[cube.x, cube.y + 1, cube.z]] += 1
  end

  if cube_hash.key?([cube.x, cube.y, cube.z - 1])
    this_neighbours += 1 
  else
    # possible_gaps[[cube.x, cube.y, cube.z - 1]] += 1
  end

  if cube_hash.key?([cube.x, cube.y, cube.z + 1])
    this_neighbours += 1 
  else
    # possible_gaps[[cube.x, cube.y, cube.z + 1]] += 1
  end

  neighbours += this_neighbours
  #trapped[[cube.x, cube.y, cube.z]] = true if this_neighbours == 6
end

npg = Hash.new
gap_neighbours = 0
possible_gaps.each do |(x, y, z), v|
  nv = 0
  nv += 1 if possible_gaps.key?([x - 1, y, z])
  nv += 1 if possible_gaps.key?([x + 1, y, z])
  nv += 1 if possible_gaps.key?([x, y - 1, z])
  nv += 1 if possible_gaps.key?([x, y + 1, z])
  nv += 1 if possible_gaps.key?([x, y, z - 1])
  nv += 1 if possible_gaps.key?([x, y, z + 1])
  gap_neighbours += nv
  #npg[[x, y, z]] = v + nv
end
#possible_gaps.merge!(npg)

trapped = possible_gaps.count { |_, v| v == 6 }
# cubes.each do |cube|
#   next if trapped.key?([cube.x, cube.y, cube.z])

#   neighbours += 1 if cube_hash.key?([cube.x - 1, cube.y, cube.z])
#   neighbours += 1 if cube_hash.key?([cube.x + 1, cube.y, cube.z])
#   neighbours += 1 if cube_hash.key?([cube.x, cube.y - 1, cube.z])
#   neighbours += 1 if cube_hash.key?([cube.x, cube.y + 1, cube.z])
#   neighbours += 1 if cube_hash.key?([cube.x, cube.y, cube.z - 1])
#   neighbours += 1 if cube_hash.key?([cube.x, cube.y, cube.z + 1])
# end

part_1 = max_faces - neighbours
part_2 = part_1 - ((trapped * 6) - gap_neighbours)

puts "Part 1: #{part_1}"
puts "Part 2: #{part_2}"
