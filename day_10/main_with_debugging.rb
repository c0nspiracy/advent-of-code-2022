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

puts "Sprite position: #{"." * (x-1)}####{"." * (38-x)}"
puts
loop do
  if ic.zero? && !input.empty?
    op, val = input.shift
    puts "Start cycle #{cycle.to_s.rjust(3)}: begin executing #{op} #{val}"

    case op
    when "noop"
      ic = 1
    when "addx"
      ic = 2
    end
  end

  puts "During cycle #{cycle.to_s.rjust(2)}: CRT draws pixel in position #{cycle - 1} (ic=#{ic}, val=#{val}, X: #{x})"

  pixel = (cycle - 1) % 40
  if (pixel >= (x - 1) && pixel <= (x + 1))
    crt_row << "#"
  else
    crt_row << "."
  end
  puts "Current CRT row: #{crt_row.join}"

  if interesting_sig_strengths.include?(cycle)
    #puts "Signal strength at #{cycle} is (#{cycle} * #{x} = #{cycle * x})"
    sig_strength += cycle * x
  end

  ic -= 1

  if ic == 0
    if val
      x += val.to_i
      puts "End of cycle #{cycle.to_s.rjust(2)}: finish executing #{op} #{val} (Register X is now #{x})"
      #puts "Sprite position: #{"." * (x-1)}####{"." * (38-x)}"
      val = nil
    else
      #puts "After the #{cycle} cycle, the #{op} instruction finishes execution, doing nothing."
    end
  end

  if cycle % 40 == 0
    display << crt_row.join
    crt_row = []
  end
  break if input.empty? && ic == 0
  cycle += 1
  puts
end

puts "Part 1: #{sig_strength}"

puts "Part 2:"
puts display.join("\n")
