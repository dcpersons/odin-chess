class Knight < Pieces
  TYPE = 'knight'

  def to_letter
    return 'n' if color == 'black'

    'N'
  end
end
