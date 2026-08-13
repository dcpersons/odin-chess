# frozen_string_literal: true

# piece subclass for rooks
class Rook < Pieces
  TYPE = 'rook'

  def symbol
    color == 'w' ? "\u2656" : "\u265C"
  end

  def valid_moves(pre_check: false)
    cardinal_moves(pre_check: pre_check)
  end

  def castle_value
    if coord == ['a', color == 'w' ? 1 : 8]
      return color == 'w' ? 'Q' : 'q'
    elsif coord == ['h', color == 'w' ? 1 : 8]
      return color == 'w' ? 'K' : 'k'
    end

    'N/A'
  end
end
