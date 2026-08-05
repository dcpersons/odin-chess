class Square
  attr_reader :coord, :file, :rank
  attr_accessor :piece

  def initialize(file, rank, game)
    @game = game
    @file = file
    @rank = rank
    @coord = file + rank.to_s
  end

  def setup_piece(letter)
    color = letter.match?(/[[:upper:]]/) ? 'white' : 'black'
    pieces = { 'r' => Rook, 'n' => Knight, 'b' => Bishop, 'q' => Queen, 'k' => King, 'p' => Pawn }
    @piece = pieces[letter.downcase].new(color, @file, @rank, @game)
  end

  def empty?
    return true if @piece.nil?

    false
  end
end
