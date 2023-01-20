# frozen_string_literal: true

input = ARGF.readlines(chomp: true).map(&:split)

x = 1
cycle = 1
ic = 0
op = nil
val = nil
sig_strength = 0
interesting_sig_strengths = [20, 60, 100, 140, 180, 220]
crt_row = []
display = []

loop do
  if ic.zero? && !input.empty?
    op, val = input.shift

    case op
    when "noop"
      ic = 1
    when "addx"
      ic = 2
    end
  end

  pixel = (cycle - 1) % 40
  if (pixel >= (x - 1) && pixel <= (x + 1))
    crt_row << "⬜"
  else
    crt_row << "⬛"
  end

  if interesting_sig_strengths.include?(cycle)
    sig_strength += cycle * x
  end

  ic -= 1

  if ic == 0
    if val
      x += val.to_i
      val = nil
    end
  end

  if cycle % 40 == 0
    display << crt_row.join
    crt_row = []
  end

  break if input.empty? && ic == 0
  cycle += 1
end

puts "Part 1: #{sig_strength}"
puts "Part 2:"
puts display.join("\n")
