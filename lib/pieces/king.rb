# frozen_string_literal: true

class King < Pieces
  TYPE = 'king'

  def valid_moves(pre_check: false)
    moves = king_moves
    moves.keep_if do |move|
      @game.on_board?(move) && (@game.empty_space?(move) || @game.other_color?(move, color))
    end
    moves << ['O-O-O'] if queen_castle?
    moves << ['O-O'] if king_castle?
    moves.delete_if { |move| !pre_check && illegal_check_move?(move) }
  end

  def castle_queenside
    @game.square_at(coord).piece = nil
    @game.square_at(['c', rank]).place_piece(color == 'w' ? 'K' : 'k')
    @game.square_at(['a', rank]).piece = nil
    @game.square_at(['d', rank]).place_piece(color == 'w' ? 'R' : 'r')
  end

  def castle_kingside
    @game.square_at(coord).piece = nil
    @game.square_at(['g', rank]).place_piece(color == 'w' ? 'K' : 'k')
    @game.square_at(['h', rank]).piece = nil
    @game.square_at(['f', rank]).place_piece(color == 'w' ? 'R' : 'r')
  end

  def castle_value
    color == 'w' ? 'KQ' : 'kq'
  end

  private

  def king_moves
    moves = [-1, 0, 1].product([-1, 0, 1])
    moves.map { |move| [(file.ord + move[0]).chr, rank + move[1]] }
  end

  def queen_castle?
    if @game.castle_rights.include?(color == 'w' ? 'Q' : 'q') &&
       @game.empty_space?(['b', rank]) &&
       @game.empty_space?(['c', rank]) &&
       @game.empty_space?(['d', rank])
      true
    else
      false
    end
  end

  def king_castle?
    if @game.castle_rights.include?(color == 'w' ? 'Q' : 'q') &&
       @game.empty_space?(['f', rank]) &&
       @game.empty_space?(['g', rank])
      true
    else
      false
    end
  end
end
