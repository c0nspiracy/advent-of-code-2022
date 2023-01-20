# frozen_string_literal: true

require "set"

class State
  include Comparable
  attr_reader :current_valve, :time, :open_valves

  def initialize(current_valve, time = 0, open_valves = [])
    @current_valve = current_valve
    @time = time
    @open_valves = open_valves.dup
  end

  def open_valve(valve)
    @open_valves << valve
  end

  def eql?(other)
    current_valve == other.current_valve &&
      time == other.time &&
      open_valves == other.open_valves
  end

  def seen_key
    [current_valve, open_valves]
  end

  def hash
    [current_valve, time, open_valves].hash
  end
end

class Volcano
  SCORES = [0, 0, 20, 20, 20, 33, 33, 33, 33, 54, 54, 54, 54, 54, 54, 54, 54, 76, 76, 76, 76, 79, 79, 79, 81, 81, 81, 81, 81, 81]

  VALID_STATES = [
    ["DD", []],
    ["DD", ["DD"]],
    ["CC", ["DD"]],
    ["BB", ["DD"]],
    ["BB", ["DD", "BB"]],
    ["AA", ["DD", "BB"]],
    ["II", ["DD", "BB"]],
    ["JJ", ["DD", "BB"]],
    ["JJ", ["DD", "BB", "JJ"]],
    ["II", ["DD", "BB", "JJ"]],
    ["AA", ["DD", "BB", "JJ"]],
    ["DD", ["DD", "BB", "JJ"]],
    ["EE", ["DD", "BB", "JJ"]],
    ["FF", ["DD", "BB", "JJ"]],
    ["GG", ["DD", "BB", "JJ"]],
    ["HH", ["DD", "BB", "JJ"]],
    ["HH", ["DD", "BB", "JJ", "HH"]],
    ["GG", ["DD", "BB", "JJ", "HH"]],
    ["FF", ["DD", "BB", "JJ", "HH"]],
    ["EE", ["DD", "BB", "JJ", "HH"]],
    ["EE", ["DD", "BB", "JJ", "HH", "EE"]],
    ["DD", ["DD", "BB", "JJ", "HH", "EE"]],
    ["CC", ["DD", "BB", "JJ", "HH", "EE"]],
    ["CC", ["DD", "BB", "JJ", "HH", "EE", "CC"]],
    ["CC", ["DD", "BB", "JJ", "HH", "EE", "CC"]],
    ["CC", ["DD", "BB", "JJ", "HH", "EE", "CC"]],
    ["CC", ["DD", "BB", "JJ", "HH", "EE", "CC"]],
    ["CC", ["DD", "BB", "JJ", "HH", "EE", "CC"]],
    ["CC", ["DD", "BB", "JJ", "HH", "EE", "CC"]],
    ["CC", ["DD", "BB", "JJ", "HH", "EE", "CC"]],
  ]

  def initialize(paths, flow_rates, full_paths, fw)
    @fw = fw
    @paths = paths
    @flow_rates = flow_rates
    @full_paths = full_paths
    @interesting_valves = flow_rates.select { |_, v| v > 0 }.keys
    start_state = State.new("AA")
    @states = { start_state => 0 }
    @seen = { start_state.seen_key => 0 }
  end

  def step
    30.times do |n|
      puts "Step #{n+1}"
      new_states = {}

      highest_score = @states.values.max
      @states.each do |current_state, current_score|
        flow_this_step = current_pressure(current_state)
        current_score += flow_this_step
        #@states[current_state] = current_score
        time_left = 30 - (n + 1)
        valves_left = @interesting_valves - current_state.open_valves
        #max_flow_left = valves_left.sum { |v| @flow_rates[v] * (time_left - 1) }
        flow_left = valves_left.map { |v| @flow_rates[v] }.sort.reverse
        max_flow_left = flow_left.zip(30.step(0, -2)).sum { _1 * _2 }

        next if current_score + (flow_this_step * time_left) + max_flow_left < highest_score

        #debug = current_state.open_valves == ["DD", "BB"]
        moves = find_paths2(current_state, current_state.current_valve)
        # if (current_state.open_valves == @interesting_valves)
        #   moves = []
        # else
          #moves = find_paths(current_state, current_state.current_valve, 30 - current_state.time, [], false)
          ##binding.irb if debug
          #moves.reject! { |_, v| v.zero? }
          #moves.select! { |k, _| @interesting_valves.include?(k.last) }
          #moves.reject! { |k, _| current_state.open_valves.include?(k.last) }
          #moves.transform_keys!(&:first)
          #binding.irb
        # end
        #

        unless current_state.open_valves.include?(current_state.current_valve)
          new_states[State.new(current_state.current_valve, current_state.time + 1, current_state.open_valves + [current_state.current_valve])] = current_score
        end
        # moves.sort_by(&:last).reverse_each do |move, score|
        moves.each do |move|
          new_states[State.new(move, current_state.time + 1, current_state.open_valves)] = current_score
        end
        if moves.empty? && current_state.open_valves.include?(current_state.current_valve)
          new_states[State.new(current_state.current_valve, current_state.time + 1, current_state.open_valves)] = current_score
        end
      end

      nss = new_states.size
      @states = new_states.reject { |state, score| @seen.key?(state.seen_key) && @seen[state.seen_key] > score }
      puts "Rejected #{nss - @states.size} states"
      @seen.merge! @states.transform_keys(&:seen_key)

      puts "States: #{@states.size}"

      # expected_score = (0..n).sum { |m| SCORES[m] }
      # s = @states.keys.detect { |s| s.current_valve == VALID_STATES[n][0] && s.open_valves == VALID_STATES[n][1] }
      # score = @states[s]
      # binding.irb unless s
      # if s
      #   puts "State #{s.inspect} = #{score}"
      #   binding.irb unless score == expected_score
      # end
    end

    @states.values.max
  end

  def simulate
    pressure_released = 0

    30.times do |minute|
      minutes_remaining = 30 - minute
      puts "== Minute #{minute + 1} =="

      display_open_valves
      pressure_released += current_pressure

      # Move or open?
      potential_pressure_release = 0
      unless @open_valves.include?(@position)
        potential_pressure_release = @flow_rates[@position] * (minutes_remaining - 1)
        puts "Potential pressure release by opening this valve (#{@position}) = #{potential_pressure_release}"
      end

      moves = find_paths(@position, minutes_remaining)
      moves.reject! { |_, v| v.zero? }
      ppr = 0
      unless moves.empty?
        best_move, ppr = moves.sort_by(&:last).last
        best_step = best_move.first
        puts "Potential moves: #{moves.sort_by(&:last).reverse.to_h}"
        puts "Best move is to #{best_step} (#{best_move.join('->')}) with potential pressure release of #{ppr}."
      end

      next if ppr.zero? && potential_pressure_release.zero?

      if ppr >= potential_pressure_release
        puts "You move to valve #{best_step}."
        @position = best_step
      else
        puts "You open valve #{@position}."
        open_valve(@position)
      end

      puts
    end

    pressure_released
  end

  def find_paths2(current_state, position)
    remaining_valves = @interesting_valves - current_state.open_valves - [position]
    remaining_valves.map do |v|
      @full_paths[[position, v]][1]
    end.uniq
  end

  def find_paths(current_state, position, minutes_remaining, seen = [], debug = false)
    return {} if seen.include?(position)

    new_paths = {}
    seen << position

    @paths[position].each do |move|
      next if seen.include?(move)
      binding.irb if debug

      if current_state.open_valves.include?(move)
        new_paths[[move]] = 0
      else
        new_paths[[move]] = @flow_rates[move] * (minutes_remaining - 2)
      end

      subpaths = find_paths(current_state, move, minutes_remaining - 1, seen.dup, debug)
      subpaths.each do |k, v|
        new_paths[[move, *k]] = v
      end
    end

    new_paths
  end

  private

  def display_open_valves
    valves = @open_valves.sort

    if valves.empty?
      puts "No valves are open."
    elsif valves.size == 1
      puts "Valve #{valves[0]} is open, releasing #{current_pressure} pressure."
    elsif valves.size == 2
      puts "Valves #{valves[0]} and #{valves[1]} are open, releasing #{current_pressure} pressure."
    else
      puts "Valves #{valves[0...-1].join(", ")}, and #{valves[-1]} are open, releasing #{current_pressure} pressure."
    end
  end

  def current_pressure(state)
    state.open_valves.sum { |valve| @flow_rates[valve] }
  end
end

input = ARGF.readlines(chomp: true)
flow_rates = {}
paths = {}
#position = "AA"
#pressure_released = 0
#open_valves = []

graph = []
input.each do |line|
  left, right = line.split("; ")
  valve, flow_rate = left.scan(/Valve (\w\w) has flow rate=(\d+)/).first
  flow_rates[valve] = flow_rate.to_i
  other_valves = right.scan(/[A-Z]{2}/)
  paths[valve] = other_valves
  other_valves.each do |ov|
    graph << [valve, ov, 1]
  end
end

def floyd_warshall(nodes, edges)
  dist = Hash.new { |h,k| h[k] = Hash.new { |h2,k2| h2[k2] = k == k2 ? 0 : Float::INFINITY } }
  #dist = Array.new(n){|i| Array.new(n){|j| i==j ? 0 : Float::INFINITY}}
  nxt = Hash.new { |h,k| h[k] = Hash.new }
  #nxt = Array.new(n){Array.new(n)}
  edges.each do |u,v,w|
    dist[u][v] = w
    nxt[u][v] = v
  end

  nodes.each do |k|
    nodes.each do |i|
      nodes.each do |j|
        if dist[i][j] > dist[i][k] + dist[k][j]
          dist[i][j] = dist[i][k] + dist[k][j]
          nxt[i][j] = nxt[i][k]
        end
      end
    end
  end

  puts "pair       dist    path"
  nodes.each do |i|
    nodes.each do |j|
      next  if i==j
      u = i
      path = [u]
      path << (u = nxt[u][j])  while u != j
      path = path.join(" -> ")
      puts "%s -> %s  %4d     %s" % [i, j, dist[i][j], path]
    end
  end
  dist
end

def reconstruct_path(tail, came_from)
  path = []

  loop do
    path << tail
    tail = came_from[tail]
    break if tail.nil?

  end

  path.reverse
end

def bfs(graph, start, goal)
  q = [start]
  came_from = { start => nil }

  loop do
    break if q.empty?
    curr = q.shift

    next unless graph.key?(curr)
    return reconstruct_path(goal, came_from) if curr == goal
    #return came_from if curr == goal

    graph[curr].each do |neighbour|
      unless came_from.key?(neighbour)
        came_from[neighbour] = curr
        q.push neighbour
      end
    end
  end
end

full_paths = {}
paths.keys.each do |left|
  (paths.keys - [left]).each do |right|
    full_paths[[left, right]] = bfs(paths, left, right)
  end
end

binding.irb

fw = floyd_warshall(paths.keys, graph)
volcano = Volcano.new(paths, flow_rates, full_paths, fw)
#part_1 = volcano.simulate
puts volcano.step
