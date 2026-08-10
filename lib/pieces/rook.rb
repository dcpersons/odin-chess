class Rook < Pieces
  TYPE = 'rook'

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
