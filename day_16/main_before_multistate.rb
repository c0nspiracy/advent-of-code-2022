# frozen_string_literal: true

class State
  attr_reader :current_valve, :time, :open_valves

  def initialize(current_valve, time, open_valves)
    @current_valve = current_valve
    @time = time
    @open_valves = open_valves.dup
  end

  def open_valve(valve)
    @open_valves << valve
  end
end

class Volcano
  def initialize(paths, flow_rates)
    @paths = paths
    @flow_rates = flow_rates
    @open_valves = []
    @position = "AA"
    @states = []
  end

  def open_valve(valve)
    @open_valves << valve
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

  def find_paths(position, minutes_remaining, seen = [])
    return {} if seen.include?(position)

    new_paths = {}
    seen << position

    @paths[position].each do |move|
      if @open_valves.include?(move)
        new_paths[[move]] = 0
      else
        new_paths[[move]] = @flow_rates[move] * (minutes_remaining - 2)
      end

      subpaths = find_paths(move, minutes_remaining - 1, seen)
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

  def current_pressure
    @open_valves.sum { |valve| @flow_rates[valve] }
  end
end

input = ARGF.readlines(chomp: true)
flow_rates = {}
paths = {}
#position = "AA"
#pressure_released = 0
#open_valves = []

input.each do |line|
  left, right = line.split("; ")
  valve, flow_rate = left.scan(/Valve (\w\w) has flow rate=(\d+)/).first
  flow_rates[valve] = flow_rate.to_i
  other_valves = right.scan(/[A-Z]{2}/)
  paths[valve] = other_valves
end

volcano = Volcano.new(paths, flow_rates)
part_1 = volcano.simulate


puts part_1
