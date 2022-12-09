# frozen_string_literal: true

require "pathname"

DISK_SPACE = 70_000_000
REQUIRED_SPACE = 30_000_000

input = ARGF.readlines(chomp: true)

filesystem = {}
current_directory = nil

input.each do |line|
  if line.start_with?("$")
    _, command, arg = line.split
    case command
    when "cd"
      if arg == "/"
        current_directory = ["/"]
      elsif arg == ".."
        current_directory.pop
      else
        current_directory.push(arg)
      end
    end
  else
    size_or_type, name = line.split
    unless size_or_type == "dir"
      stack = []
      current_directory.each do |subdir|
        if stack.empty?
          filesystem[subdir] ||= Hash.new
        else
          filesystem.dig(*stack)[subdir] ||= Hash.new
        end
        stack << subdir
      end
      filesystem.dig(*current_directory)[name] = size_or_type.to_i
    end
  end
end

def directory_sizes(filesystem)
  sizes = Hash.new { |h, k| h[k] = 0 }

  filesystem.each do |path, value|
    if value.is_a?(Hash)
      subdirectory_sizes = directory_sizes(value)
      sizes["."] += subdirectory_sizes["."] unless path == "/"
      subdirectory_sizes.transform_keys! { |subdirectory| (Pathname.new(path) + subdirectory).to_s }

      sizes.merge!(subdirectory_sizes)
    else
      sizes["."] += value
    end
  end

  sizes
end

dir_sizes = directory_sizes(filesystem)
sizes = dir_sizes.values.sort

part_1 = sizes.select { |size| size <= 100_000 }.sum
puts "Part 1: #{part_1}"

space_to_delete = REQUIRED_SPACE - (DISK_SPACE - dir_sizes["/"])
part_2 = sizes.bsearch { |size| size >= space_to_delete }
puts "Part 2: #{part_2}"
