# frozen_string_literal: true

require_relative '../pieces'

# piece subclass for pawns
class Pawn < Pieces
  TYPE = 'pawn'

  def initialize(color, file, rank, game)
    super
    @game.pawn_move = true
  end

  def symbol
    color == 'w' ? "\u2659" : "\u265F"
  end

  def valid_moves(pre_check: false)
    moves = color == 'w' ? white_moves : black_moves
    moves.keep_if { |move| @game.on_board?(move) && (valid_step?(move) || valid_take?(move)) }
    moves.delete_if { |move| !pre_check && illegal_check_move?(move) }
    moves = moves.product(%w[R N B Q]).map(&:flatten) if promotable?
    moves
  end

  def promotable?
    color == 'w' && rank == 7 || color == 'b' && rank == 2
  end

  def double_step?(start)
    [start[1] + 2, start[1] - 2].include?(rank)
  end

  private

  def white_moves
    [[@file, @rank + 1], [@file, @rank + 2],
     [file_left(@file), @rank + 1], [file_right(@file), @rank + 1]]
  end

  def black_moves
    [[@file, @rank - 1], [@file, @rank - 2],
     [file_left(@file), @rank - 1], [file_right(@file), @rank - 1]]
  end

  def valid_step?(move)
    return true if @game.empty_space?(move) && move[0] == file &&
                   ([rank + 1, rank - 1].include?(move[1]) || rank == 2 || rank == 7)

    false
  end

  def valid_take?(move)
    return true if move[0] != file &&
                   (@game.en_passant == move.join ||
                   @game.other_color?(move, color))

    false
  end
end
