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
    return 'Q' if coord == ['a', 1]
    return 'q' if coord == ['a', 8]
    return 'K' if coord == ['h', 1]
    return 'k' if coord == ['h', 8]

    'N/A'
  end
end
