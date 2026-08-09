class Bishop < Pieces
  TYPE = 'bishop'

  def valid_moves(pre_check: false)
    diagonal_moves(pre_check: pre_check)
  end
end
