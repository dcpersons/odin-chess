# frozen_string_literal: true

# piece subclass for bishops
class Bishop < Pieces
  TYPE = 'bishop'

  def symbol
    color == 'w' ? "\u2657" : "\u265D"
  end

  def valid_moves(pre_check: false)
    diagonal_moves(pre_check: pre_check)
  end
end
