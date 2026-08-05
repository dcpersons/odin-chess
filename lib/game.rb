require_relative 'square'
require_relative 'pieces'

class Game
  attr_reader :board, :turn, :castle_rights, :en_passant, :draw_moves, :turn_number

  def initialize(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    @board = make_board
    setup_game(fen)
  end

  def make_board
    board = { 'a' => [], 'b' => [], 'c' => [], 'd' => [],
              'e' => [], 'f' => [], 'g' => [], 'h' => [] }
    board.each_key do |file|
      9.times { |rank| board[file][rank] = Square.new(file, rank, self) unless rank.zero? }
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

  def to_fen
    "#{board_to_fen} #{variables_to_fen}"
  end

  private

  def setup_board(fen)
    8.downto(1) do |rank|
      8.times do |n|
        if fen[0].is_a?(Integer)
          fen[0] -= 1
          fen.shift if fen[0].zero?
          next
        end
        file = ('a'.ord + n).chr
        @board[file][rank].setup_piece(fen.shift)
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

  def board_to_fen
    fen = []
    8.downto(1) do |rank|
      9.times do |n|
        next fen << '/' if n == 8

        file = ('a'.ord + n).chr
        if @board[file][rank].piece.nil?
          fen << 0 unless fen[-1].is_a?(Integer)
          fen[-1] += 1
        else
          fen << @board[file][rank].piece.to_letter
        end
      end
    end
    fen.join.slice(0..-2)
  end

  def variables_to_fen
    [@turn, @castle_rights, @en_passant, @draw_moves, @turn_number].join(' ')
  end
end
