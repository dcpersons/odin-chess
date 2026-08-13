# frozen_string_literal: true

# module for extra board-based methods for chess game
module Board
  def to_fen
    "#{board_to_fen} #{variables_to_fen}"
  end

  def make_board
    board = { 'a' => [], 'b' => [], 'c' => [], 'd' => [],
              'e' => [], 'f' => [], 'g' => [], 'h' => [] }
    board.each_key do |file|
      9.times { |rank| board[file][rank] = Square.new(file, rank, self) unless rank.zero? }
    end
  end

  def setup_game(fen)
    fen = fen.split
    fen_pieces = fen[0].split('').map { |chr| (1..8).include?(chr.to_i) ? chr.to_i : chr }
    fen_pieces.delete('/')
    fen_variables = fen[1..]
    setup_board(fen_pieces)
    setup_variables(fen_variables)
  end

  def on_board?(coord)
    coord && coord[0]&.match?(/^[a-h]+$/i) && (1..8).include?(coord[1])
  end

  def square_at(coord)
    board.dig(coord[0], coord[1])
  end

  def empty_space?(coord)
    on_board?(coord) && piece_at(coord).nil?
  end

  def piece_at(coord)
    return find_piece('K') if %w[O-O-O O-O].include?(coord[0].downcase)

    board.dig(coord[0], coord[1])&.piece
  end

  def other_color?(coord, color = @turn)
    on_board?(coord) && !empty_space?(coord) && piece_at(coord)&.color != color
  end

  private

  def setup_board(fen) # rubocop:disable Metrics/MethodLength
    8.downto(1) do |rank|
      8.times do |n|
        if fen[0].is_a?(Integer)
          fen[0] -= 1
          fen.shift if fen[0].zero?
        else
          file = ('a'.ord + n).chr
          square_at([file, rank]).place_piece(fen.shift)
        end
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

  def board_to_fen # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
    fen = []
    8.downto(1) do |rank|
      9.times do |n|
        next fen << '/' if n == 8

        file = ('a'.ord + n).chr
        if empty_space?([file, rank])
          fen << 0 unless fen[-1].is_a?(Integer)
          fen[-1] += 1
        else
          fen << piece_at([file, rank]).to_letter
        end
      end
    end
    fen[0..-2].join
  end

  def variables_to_fen
    [@turn, @castle_rights, @en_passant, @draw_moves, @turn_number].join(' ')
  end
end
