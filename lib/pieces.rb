class Pieces
  attr_reader :color, :file, :rank, :coord

  def initialize(color, file, rank, game)
    @game = game
    @color = color
    @file = file
    @rank = rank
    @coord = [file, rank]
  end

  def type
    self.class::TYPE
  end

  def to_letter
    color == 'w' ? type.chr.upcase : type.chr
  end

  def valid_moves(pre_check: false)
    []
  end

  def illegal_check_move?(move)
    sim_game = @game.clone
    sim_game.square_at(coord).piece = nil
    sim_game.square_at(move).place_piece(to_letter)
    sim_game.check?
  end

  private

  def cardinal_moves(pre_check: false)
    square = coord
    moves = up(square) | down(square) | left(square) | right(square)
    moves.delete_if { |move| !pre_check && illegal_check_move?(move) }
    moves
  end

  def diagonal_moves(pre_check: false)
    square = coord
    moves = up_left(square) | up_right(square) | down_left(square) | down_right(square)
    moves.delete_if { |move| !pre_check && illegal_check_move?(move) }
    moves
  end

  def up(move)
    moves = []
    until !on_board?(move) || @game.piece_at(move) && move != coord
      move = [move[0], move[1] + 1]
      break unless on_board?(move)

      moves << move if empty_space?(move) || other_color?(move)
    end
    moves
  end

  def down(move)
    moves = []
    until !on_board?(move) || @game.piece_at(move) && move != coord
      move = [move[0], move[1] - 1]
      break unless on_board?(move)

      moves << move if empty_space?(move) || other_color?(move)
    end
    moves
  end

  def left(move)
    moves = []
    until !on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_left(move[0]), move[1]]
      break unless on_board?(move)

      moves << move if empty_space?(move) || other_color?(move)
    end
    moves
  end

  def right(move)
    moves = []
    until !on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_right(move[0]), move[1]]
      break unless on_board?(move)

      moves << move if empty_space?(move) || other_color?(move)
    end
    moves
  end

  def up_left(move)
    moves = []
    until !on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_left(move[0]), move[1] + 1]
      break unless on_board?(move)

      moves << move if empty_space?(move) || other_color?(move)
    end
    moves
  end

  def up_right(move)
    moves = []
    until !on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_right(move[0]), move[1] + 1]
      break unless on_board?(move)

      moves << move if empty_space?(move) || other_color?(move)
    end
    moves
  end

  def down_left(move)
    moves = []
    until !on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_left(move[0]), move[1] - 1]
      break unless on_board?(move)

      moves << move if empty_space?(move) || other_color?(move)
    end
    moves
  end

  def down_right(move)
    moves = []
    until !on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_right(move[0]), move[1] - 1]
      break unless on_board?(move)

      moves << move if empty_space?(move) || other_color?(move)
    end
    moves
  end

  def on_board?(move)
    move && move[0]&.match?(/^[a-h]+$/i) && (1..8).include?(move[1])
  end

  def empty_space?(move)
    return true if move && @game.piece_at(move).nil?

    false
  end

  def other_color?(move)
    return false if empty_space?(move) || @game.piece_at(move).color == color

    true
  end

  private

  def file_left(file = @file)
    (file.ord - 1).chr
  end

  def file_right(file = @file)
    (file.ord + 1).chr
  end
end

Dir.glob('lib/pieces/**.rb') { |name| require_relative "../#{name}" }
