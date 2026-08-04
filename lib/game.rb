require_relative 'square'
require_relative 'pieces'

class Game
  attr_reader :board

  def initialize(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    @board = make_board
    setup_game(fen)
  end

  def make_board
    board = { 'a' => Array.new(9), 'b' => Array.new(9), 'c' => Array.new(9), 'd' => Array.new(9),
              'e' => Array.new(9), 'f' => Array.new(9), 'g' => Array.new(9), 'h' => Array.new(9) }
    board.each_key do |column|
      9.times { |row| board[column][row] = Square.new(column, row) unless row.zero? }
    end
    board
  end

  def setup_game(fen)
    fen = fen.split
    fen_pieces = fen[0].split('').map { |chr| (1..8).include?(chr.to_i) ? chr.to_i : chr }
    fen_pieces.delete('/')
    fen_variables = fen[1..]
    setup_board(fen_pieces)
    setup_variables(fen_variables)
  end

  def setup_board(fen)
    8.downto(1) do |row|
      8.times do |n|
        if fen[0].is_a?(Integer)
          fen[0] -= 1
          fen.shift if fen[0].zero?
          next
        end
        column = ('a'.ord + n).chr
        @board[column][row].set_piece(fen.shift)
      end
    end
  end

  def setup_variables(fen)
    @turn = fen.shift
    @castle_rights = fen.shift
    @en_passant = fen.shift
    @draw_moves = fen.shift.to_i
    @turn_number = fen.shift.to_i
  end

  def to_fen
    "#{board_to_fen} #{variables_to_fen}"
  end

  def board_to_fen
    fen = []
    8.downto(1) do |row|
      9.times do |n|
        next fen << '/' if n == 8

        column = ('a'.ord + n).chr
        if @board[column][row].piece.nil?
          fen << 0 unless fen[-1].is_a?(Integer)
          fen[-1] += 1
        else
          fen << @board[column][row].piece.to_letter
        end
      end
    end
    fen.join
  end

  def variables_to_fen
    [@turn, @castle_rights, @en_passant, @draw_moves, @turn_number].join(' ')
  end
end
