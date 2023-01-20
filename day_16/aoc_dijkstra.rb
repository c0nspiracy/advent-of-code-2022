def dijkstra(grid, paths)
  q = []
  dist = Hash.new(Float::INFINITY)
  prev = {}

  dest_y = 0
  dest_x = 0
  grid.each_with_index do |row, y|
    row.each_with_index do |elevation, x|
      if elevation == "E"
        dist[[y, x]] = 0
      end
      if elevation == "S"
        dest_y, dest_x = y, x
      end
      prev[[y, x]] = nil
      q << [y, x]
    end
  end

  loop do
    break if q.empty?

    uy, ux = q.min_by { |y, x| dist[[y, x]] }

    q.delete([uy, ux])
    break if uy == dest_y && ux == dest_x

    paths[[uy, ux]].each do |vy, vx|
      next unless q.include?([vy, vx])

      alt = dist[[uy, ux]] + 1
      if alt < dist[[vy, vx]]
        dist[[vy, vx]] = alt
        prev[[vy, vx]] = [uy, ux]
      end
    end
  end

  dist
end

