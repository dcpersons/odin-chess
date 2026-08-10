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

  def illegal_check_move?(move)
    sim_game = Game.new(@game.to_fen)
    if move == ['O-O-O']
      sim_game.piece_at(coord).castle_queenside
    elsif move == ['O-O']
      sim_game.piece_at(coord).castle_kingside
    else
      sim_game.square_at(coord).piece = nil
      sim_game.square_at(move).place_piece(to_letter)
    end
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
    until !@game.on_board?(move) || @game.piece_at(move) && move != coord
      move = [move[0], move[1] + 1]
      break unless @game.on_board?(move)

      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
    end
    moves
  end

  def down(move)
    moves = []
    until !@game.on_board?(move) || @game.piece_at(move) && move != coord
      move = [move[0], move[1] - 1]
      break unless @game.on_board?(move)

      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
    end
    moves
  end

  def left(move)
    moves = []
    until !@game.on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_left(move[0]), move[1]]
      break unless @game.on_board?(move)

      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
    end
    moves
  end

  def right(move)
    moves = []
    until !@game.on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_right(move[0]), move[1]]
      break unless @game.on_board?(move)

      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
    end
    moves
  end

  def up_left(move)
    moves = []
    until !@game.on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_left(move[0]), move[1] + 1]
      break unless @game.on_board?(move)

      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
    end
    moves
  end

  def up_right(move)
    moves = []
    until !@game.on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_right(move[0]), move[1] + 1]
      break unless @game.on_board?(move)

      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
    end
    moves
  end

  def down_left(move)
    moves = []
    until !@game.on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_left(move[0]), move[1] - 1]
      break unless @game.on_board?(move)

      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
    end
    moves
  end

  def down_right(move)
    moves = []
    until !@game.on_board?(move) || @game.piece_at(move) && move != coord
      move = [file_right(move[0]), move[1] - 1]
      break unless @game.on_board?(move)

      moves << move if @game.empty_space?(move) || @game.other_color?(move, color)
    end
    moves
  end
end

Dir.glob('lib/pieces/**.rb') { |name| require_relative "../#{name}" }
