class Knight < Pieces
  TYPE = 'knight'

  def valid_moves(pre_check: false)
    moves = knight_moves
    moves.keep_if do |move|
      @game.on_board?(move) &&
        (@game.empty_space?(move) || @game.other_color?(move, color))
    end
    moves.delete_if { |move| !pre_check && illegal_check_move?(move) }
  end

  def to_letter
    color == 'w' ? 'N' : 'n'
  end

  private

  def knight_moves
    ([-2, 2].product([-1, 1]) | [-1, 1].product([-2, 2])).map do |move|
      [(file.ord + move[0]).chr, rank + move[1]]
    end
  end
end
