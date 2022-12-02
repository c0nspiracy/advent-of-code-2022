# frozen_string_literal: true

# A/X = Rock
# B/Y = Paper
# C/Z = Scissors

SHAPE_SCORE = { "X" => 1, "Y" => 2, "Z" => 3 }

OUTCOME_SCORE = {
  # 0 = Lose, 3 = Draw, 6 = Win
  "A" => { "X" => 3, "Y" => 6, "Z" => 0 },
  "B" => { "X" => 0, "Y" => 3, "Z" => 6 },
  "C" => { "X" => 6, "Y" => 0, "Z" => 3 }
}

def shape_for_outcome(opponent, player)
  # The OUTCOME_SCORE value for "B" handily already contains a mapping
  # between X, Y & Z and the scores for losing, drawing & winning.
  target_score = OUTCOME_SCORE["B"][player]

  # Reverse lookup to find the required shape to achieve the target score
  OUTCOME_SCORE[opponent].invert[target_score]
end

strategy_guide = ARGF.readlines(chomp: true)

part_1_score = 0
part_2_score = 0

strategy_guide.each do |round|
  opponent, part_1_player = round.split
  part_2_player = shape_for_outcome(opponent, part_1_player)

  part_1_score += SHAPE_SCORE[part_1_player] + OUTCOME_SCORE[opponent][part_1_player]
  part_2_score += SHAPE_SCORE[part_2_player] + OUTCOME_SCORE[opponent][part_2_player]
end

puts "Part 1: #{part_1_score}"
puts "Part 2: #{part_2_score}"
