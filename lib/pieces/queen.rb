# frozen_string_literal: true

# piece subclass for queens
class Queen < Pieces
  TYPE = 'queen'

  def symbol
    color == 'w' ? "\u2655" : "\u265B"
  end

  def valid_moves(pre_check: false)
    cardinal_moves(pre_check: pre_check) | diagonal_moves(pre_check: pre_check)
  end
end
