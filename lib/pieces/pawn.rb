require_relative '../pieces'

class Pawn < Pieces
  TYPE = 'pawn'

  def valid_moves
    moves = @color == 'white' ? white_moves : black_moves
    moves = moves.except(:single_step, :double_step) unless empty_space?(moves[:single_step])
    moves.delete(:double_step) unless empty_space?(moves[:double_step])
    moves.delete(:take_left) unless valid_take?(moves[:take_left])
    moves.delete(:take_right) unless valid_take?(moves[:take_right])
  end

  private

  def white_moves
    moves = { single_step: [@file, @rank + 1],
              double_step: ([@file, @rank + 2] if @rank == 2),
              take_left: [(@file.ord - 1).chr, @rank + 1],
              take_right: [(@file.ord + 1).chr, @rank + 1] }

    moves.delete_if { |_, move| off_board?(move) }
  end

  def black_moves
    moves = { single_step: [@file, @rank - 1],
              double_step: ([@file, @rank - 2] if @rank == 7),
              take_left: [(@file.ord - 1).chr, @rank - 1],
              take_right: [(@file.ord + 1).chr, @rank - 1] }

    moves.delete_if { |_, move| off_board?(move) }
  end

  def valid_take?(move)
    return true if @game.en_passant == move.join ||
                   other_color?(move, @color)

    false
  end
end
