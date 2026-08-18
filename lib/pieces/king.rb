# frozen_string_literal: true

# piece subclass for kings
class King < Pieces
  TYPE = 'king'

  def symbol
    color == 'w' ? "\u2654" : "\u265A"
  end

  def valid_moves(pre_check: false)
    moves = king_moves
    moves << ['O-O-O'] if queen_castle?
    moves << ['O-O'] if king_castle?
    moves.delete_if { |move| !pre_check && illegal_check_move?(move) }
  end

  def castle_queenside
    @game.move_info(self, ['c', rank])
    @game.square_at(coord).piece = nil
    @game.square_at(['c', rank]).place_piece(color == 'w' ? 'K' : 'k')
    @game.square_at(['a', rank]).piece = nil
    @game.square_at(['d', rank]).place_piece(color == 'w' ? 'R' : 'r')
  end

  def castle_kingside
    @game.move_info(self, ['g', rank])
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
    moves = moves.map { |move| [(file.ord + move[0]).chr, rank + move[1]] }
    moves.keep_if do |move|
      @game.on_board?(move) && (@game.empty_space?(move) || @game.other_color?(move, color))
    end
  end

  def queen_castle?
    @game.castle_rights.include?(color == 'w' ? 'Q' : 'q') &&
      @game.empty_space?(['b', rank]) &&
      @game.empty_space?(['c', rank]) &&
      @game.empty_space?(['d', rank])
  end

  def king_castle?
    @game.castle_rights.include?(color == 'w' ? 'K' : 'k') &&
      @game.empty_space?(['f', rank]) &&
      @game.empty_space?(['g', rank])
  end
end
