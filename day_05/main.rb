# frozen_string_literal: true

require "active_support/core_ext/object"

class DaySix
  def initialize(input)
    @stacks, @procedure = parse_input(input)
  end

  def rearrange(preserve_order:)
    with_copy_of_stacks do |stacks|
      @procedure.each do |step|
        quantity, source, destination = step.scan(/\d+/).map(&:to_i)
        crates = stacks[source].pop(quantity)
        crates.reverse! unless preserve_order
        stacks[destination].push(*crates)
      end
    end
  end

  private

  def parse_input(input)
    stacks, procedure = input.split("\n\n").map { _1.split("\n") }
    [parse_stacks(stacks), procedure]
  end

  def parse_stacks(input)
    input.reverse.map(&:chars).transpose.slice(1.step(by: 4)).to_h do |n, *stack|
      [n.to_i, stack.reject { _1 == " " }]
    end
  end

  def with_copy_of_stacks
    @stacks.deep_dup.tap do |stacks|
      yield stacks
    end
  end
end

day_six = DaySix.new(ARGF.read)
part_1 = day_six.rearrange(preserve_order: false)
part_2 = day_six.rearrange(preserve_order: true)

puts "Part 1: #{part_1.values.map(&:last).join}"
puts "Part 2: #{part_2.values.map(&:last).join}"
