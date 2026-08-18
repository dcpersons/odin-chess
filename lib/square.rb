# frozen_string_literal: true

# class for creating squares on chess board
class Square
  attr_reader :coord, :file, :rank
  attr_accessor :piece

  def initialize(file, rank, game)
    @game = game
    @file = file
    @rank = rank
    @coord = [file, rank]
    @piece = nil
  end

  def to_s
    symbol = piece ? " #{piece.symbol} " : '   '
    if %w[a c e g].include?(file) && rank.odd? || %w[b d f h].include?(file) && rank.even?
      symbol.colorize(color: :black, background: :gray)
    else
      symbol.colorize(color: :black, background: :white)
    end
  end

  def place_piece(letter)
    color = letter.match?(/[[:upper:]]/) ? 'w' : 'b'
    pieces = { 'r' => Rook, 'n' => Knight, 'b' => Bishop, 'q' => Queen, 'k' => King, 'p' => Pawn }
    @piece = pieces[letter.downcase].new(color, @file, @rank, @game)
  end

  def empty?
    @piece.nil?
  end
end
