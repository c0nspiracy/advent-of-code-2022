# frozen_string_literal: true

ROBOT_NAMES = {
  "ore"      => "ore-collecting",
  "clay"     => "clay-collecting",
  "obsidian" => "obsidian-collecting",
  "geode"    => "geode-cracking"
}.freeze

input = ARGF.readlines(chomp: true)
blueprints = {}

input.each do |line|
  left, right = line.split(":")
  robots = right.split(".")
  blueprint_id = left.scan(/Blueprint (\d+)/).first.first
  blueprint = {}
  robots.each do |robot|
    type, costs = robot.split(" costs ")
    robot_type = type.scan(/Each (\w+) robot/).first.first
    cost_hash = costs.scan(/(\d+) (\w+)/).map { [_2, _1.to_i] }.to_h
    blueprint[robot_type] = cost_hash
  end
  blueprints[blueprint_id.to_i] = blueprint
end

pack = { "ore" => 0, "clay" => 0, "obsidian" => 0, "geode" => 0 }
robots = { "ore" => 1 }

blueprint = blueprints[1]
minute = 1
loop do
  break if minute > 24
  puts "== Minute #{minute} =="

  binding.irb
  robots.each do |resource, qty|
    pack[resource] += qty
    puts "#{qty} #{ROBOT_NAMES[resource]} robot collects #{qty} #{resource}; you now have #{pack[resource]} #{resource}."
  end

  puts
  minute += 1
end
