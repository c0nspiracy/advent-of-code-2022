# frozen_string_literal: true

def bfs(graph, start, goal)
  q = [start]
  came_from = { start => nil }

  loop do
    break if q.empty?
    curr = q.shift

    next unless graph.key?(curr)
    return came_from if curr == goal

    graph[curr].each do |neighbour|
      unless came_from.key?(neighbour)
        came_from[neighbour] = curr
        q.push neighbour
      end
    end
  end
end

def reconstruct_path(tail, came_from)
  path = []

  loop do
    tail = came_from[tail]
    break if tail.nil?

    path << tail
  end

  path.reverse
end

elevation = Hash[("a".."z").zip(1..26)]
elevation["S"] = elevation["a"]
elevation["E"] = elevation["z"]

paths = Hash.new { |h, k| h[k] = [] }
start = nil
goal = nil
grid = ARGF.readlines(chomp: true).map(&:chars)

elevation_a = []
grid.each_with_index do |row, y|
  row.each_with_index do |cell, x|
    start = [y, x] if cell == "S"
    goal = [y, x] if cell == "E"
    elevation_a << [y, x] if elevation[cell] == 1

    neighbours = []
    neighbours << [y - 1, x] if y > 0
    neighbours << [y, x - 1] if x > 0
    neighbours << [y, x + 1] if x < row.length - 1
    neighbours << [y + 1, x] if y < grid.length - 1

    neighbours.each do |ny, nx|
      if elevation[grid[ny][nx]] - elevation[cell] >= -1
        paths[[y, x]] << [ny, nx]
      end
    end
  end
end

bfs_results = bfs(paths, goal, start)
part_1 = reconstruct_path(start, bfs_results).length
puts "Part 1: #{part_1}"

part_2 = elevation_a.map { |y, x| reconstruct_path([y, x], bfs_results) }.reject(&:empty?).map(&:size).min
puts "Part 2: #{part_2}"
