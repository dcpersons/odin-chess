# frozen_string_literal: true

# class for creating chess pieces
class Pieces
  attr_reader :color, :file, :rank, :coord

  def initialize(color, file, rank, game)
    @game = game
    @color = color
    @file = file
    @rank = rank
    @coord = [file, rank]
    @game.pawn_move = false
  end

  def type
    self.class::TYPE
  end

  def to_letter
    color == 'w' ? type.chr.upcase : type.chr
  end

  def illegal_check_move?(move)
    sim_game = Game.new(@game.to_fen)
    sim_game.move(coord, move)
    sim_game.check?
  end

  def castle_value
    'N/A'
  end

  def file_left(file = @file)
    (file.ord - 1).chr
  end

  def file_right(file = @file)
    (file.ord + 1).chr
  end

  def double_step?(_)
    false
  end

  private

  def cardinal_moves(pre_check: false)
    moves = vertical('up') | vertical('down') | horizontal('left') | horizontal('right')
    moves.delete_if { |move| !pre_check && illegal_check_move?(move) }
    moves
  end

  def diagonal_moves(pre_check: false)
    moves = up_diagonal('left') | up_diagonal('right') | down_diagonal('left') | down_diagonal('right')
    moves.delete_if { |move| !pre_check && illegal_check_move?(move) }
    moves
  end

  def vertical(dir)
    moves = []
    move = coord
    loop do
      move = [move[0], dir == 'up' ? move[1] + 1 : move[1] - 1]
      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
      break if !@game.on_board?(move) || @game.piece_at(move)
    end
    moves
  end

  def horizontal(dir)
    moves = []
    move = coord
    loop do
      move = [dir == 'left' ? file_left(move[0]) : file_right(move[0]), move[1]]
      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
      break if !@game.on_board?(move) || @game.piece_at(move)
    end
    moves
  end

  def up_diagonal(dir)
    moves = []
    move = coord
    loop do
      move = [dir == 'left' ? file_left(move[0]) : file_right(move[0]), move[1] + 1]
      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
      break if !@game.on_board?(move) || @game.piece_at(move)
    end
    moves
  end

  def down_diagonal(dir)
    moves = []
    move = coord
    loop do
      move = [dir == 'left' ? file_left(move[0]) : file_right(move[0]), move[1] - 1]
      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
      break if !@game.on_board?(move) || @game.piece_at(move)
    end
    moves
  end
end

Dir.glob('lib/pieces/**.rb') { |name| require_relative "../#{name}" }
