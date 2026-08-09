class Rook < Pieces
  TYPE = 'rook'

  def valid_moves(pre_check: false)
    cardinal_moves(pre_check: pre_check)
  end
end
