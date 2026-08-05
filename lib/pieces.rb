class Pieces
  attr_reader :color, :file, :rank, :coord

  def initialize(color, file, rank, game)
    @game = game
    @color = color
    @file = file
    @rank = rank
    @coord = file + rank.to_s
  end

  def type
    self.class::TYPE
  end

  def to_letter
    letter = type[0]
    return letter.upcase if color == 'white'

    letter
  end

  private

  def on_board?(move)
    move[0].match?(/^[a-h]+$/i) && (1..8).include?(move[1])
  end

  def empty_space?(move)
    p "#{move[0]}#{move[1]}"
    return true if @game.board[move[0]][move[1]].piece.nil?

    false
  end

  def other_color?(move, color)
    return false if empty_space?(move) || @game.board[move[0]][move[1]].piece.color == color

    true
  end
end

Dir.glob('lib/pieces/**.rb') { |name| require_relative "../#{name}" }
