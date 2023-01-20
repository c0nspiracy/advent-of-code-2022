
# frozen_string_literal: true

input = ARGF.readlines(chomp: true).map(&:to_i)

position_map = {}
(0...input.size).each do |i|
  position_map[i] = i
end

puts "Initial arrangement:"
puts input.join(", ")

original_input = input.dup
original_input.each_with_index do |val, original_index|
  puts
  if val == 0
    puts "0 does not move:"
    puts input.join(", ")
    next
  end

  index = position_map[original_index]
  #val = input.delete_at(original_index)

  input.delete_at(index)
  wrap = false
  if val < 0
    new_index = (index + val)
    if new_index < 0
      new_index %= input.size
      wrap = true
    end
  else
    new_index = (index + val) % input.size
  end

  puts "#{val} moves between #{input[new_index-1]} and #{input[new_index]}:"
  input.insert(new_index, val)

  if new_index > index
    puts "updating position of #{val} from ##{index} to ##{new_index}..."
    puts "old positions: #{position_map.map { |oi, i| [original_input[oi], i] }.to_h}"
    if wrap
      index.downto(index + val).each do |i|
        wi = i % input.size
        wii = (i + 1) % input.size
        temp = position_map[wii]
        position_map[wii] = position_map[wi]
        position_map[wi] = temp
        puts "    positions: #{position_map.map { |oi, i| [original_input[oi], i] }.to_h}"
      end
    else
      (index...new_index).each do |i|
        temp = position_map[i]
        position_map[i] = position_map[i + 1]
        position_map[i + 1] = temp
        puts "    positions: #{position_map.map { |oi, i| [original_input[oi], i] }.to_h}"
      end
    end
    puts "new positions: #{position_map.map { |oi, i| [original_input[oi], i] }.to_h}"
  elsif new_index < index
    puts "old positions: #{position_map.values}"
    (new_index...index).each do |i|
      temp = position_map[i]
      position_map[i] = position_map[i + 1]
      position_map[i + 1] = temp
    end
    puts "new positions: #{position_map.values}"
  end

  #position_map[original_index] = new_index
  #position_map[new_index] = original_index

  puts input.join(", ")

  ### Sanity check
  position_map.each do |original_index, new_index|
    unless original_input[original_index] == input[new_index]
      puts "Mismatch!" 
      puts "Position map is: #{position_map}"
      should_be = original_input.map.with_index do |oval, oi|
        [oi, input.index(oval)]
      end.to_h
      puts "  but should be: #{should_be}"

      binding.irb
    end
  end
end
