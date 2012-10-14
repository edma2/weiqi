require './models'

# Load a board from an ascii description string.
#
# Top left starts at (0, 0).
#
# * is black
# 0 is white
# . is empty
# $ for new row
# Ignores everything else including whitespace
#
# Example:
# ...0.$
# ..***$
# 0*.0.$
# 00***$
# .0.0*
def load_board(description)
  stones = []
  x, y = 0, 0
  description.split('').each do |char|
    next unless ".0*$".include?(char)
    if char == '0'
      stones << Stone.new(x, y, 1)
    elsif char == '*'
      stones << Stone.new(x, y, 0)
    end
    x += 1
    if char == '$' || x == 19
      y += 1
      x = 0
    end
  end
  Board.new(stones)
end
