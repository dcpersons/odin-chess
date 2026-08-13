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

  def place_piece(letter)
    color = letter.match?(/[[:upper:]]/) ? 'w' : 'b'
    pieces = { 'r' => Rook, 'n' => Knight, 'b' => Bishop, 'q' => Queen, 'k' => King, 'p' => Pawn }
    @piece = pieces[letter.downcase].new(color, @file, @rank, @game)
  end

  def empty?
    return true if @piece.nil?

    false
  end
end
