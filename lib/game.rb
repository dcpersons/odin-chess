# frozen_string_literal: true

require_relative 'square'
require_relative 'pieces'
require_relative 'board'

# class for creating Games of chess
class Game
  attr_reader :board, :turn, :castle_rights, :en_passant, :draw_moves, :turn_number
  attr_writer :pawn_move

  include Board

  def initialize(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    @board = make_board
    setup_game(fen)
  end

  def play_game
    loop do
      move = player_move
      move(move[1], move[0])
      return winner if check_mate?
      return draw if stalemate?
    end
  end

  def player_move
    loop do
      put_board
      puts "#{@turn == 'w' ? 'White' : 'Black'} to move."
      move = gets.chomp
      return decipher(move)
    rescue StandardError => e
      puts "Error: #{e.message}. Please try again."
      sleep(0.5)
    end
  end

  def move(start, target)
    piece = piece_at(start)
    raise(StandardError, 'Invalid move') unless piece.valid_moves.include?(target)

    if target == ['O-O-O'] then castle_queenside
    elsif target == ['O-O'] then castle_kingside
    else standard_move(start, target, piece)
    end
    update_variables(start, target, piece.castle_value)
  end

  def check?
    pieces = find_pieces(next_turn, both_kings: true)
    king = pieces.find { |piece| piece.instance_of?(King) && piece.color == @turn }
    pieces.any? { |piece| piece.valid_moves(pre_check: true).include?(king.coord) }
  end

  def find_pieces(color, both_kings: false)
    pieces = []
    @board.each_value do |file|
      file.each { |square| pieces << square.piece unless square&.piece.nil? }
    end
    pieces.keep_if { |piece| piece.color == color || piece.is_a?(King) && both_kings }
  end

  def en_passant_take(target, color)
    if color == 'w'
      square_at([target[0], target[1] - 1]).piece = nil
    else
      square_at([target[0], target[1] + 1]).piece = nil
    end
  end

  def decipher(move)
    return [find_piece('K').coord, [move]] if ['O-O-O', 'O-O'].include?(move)

    move = move.split('')
    letter = if %w[R N B Q K P].include?(move[0]) then move.shift
             else 'P'
             end
    target = [move.delete_at(-2), move.pop.to_i]
    file = move.shift if move[0].to_i.zero?
    rank = move.shift&.to_i
    piece = find_piece(letter, file, rank, target)
    [piece.coord, target]
  end

  def find_piece(letter, file = nil, rank = nil, target = nil)
    pieces = find_pieces(@turn)
    piece = pieces.select do |piece|
      (piece.to_letter.upcase == letter) &&
        (target.nil? || piece.valid_moves.include?(target)) &&
        (!file || piece.file == file) &&
        (!rank || piece.rank == rank)
    end
    raise(StandardError, 'Invalid move') if piece.empty?

    raise(StandardError, 'Unspecified piece') if piece.length > 1

    piece.pop
  end

  private

  def standard_move(start, target, piece)
    @piece_taken = !empty_space?(target)
    en_passant_take(target, piece.color) if en_passant == target.join && piece_at(start).is_a?(Pawn)
    square_at(start).piece = nil
    square_at(target).place_piece(piece.to_letter)
  end

  def next_turn
    @turn == 'w' ? 'b' : 'w'
  end

  def update_variables(start, target, castle_value)
    piece = piece_at(target)
    @castle_rights.delete!(castle_value)
    @en_passant = '-'
    update_en_passant(start, piece) if double_step?(start, piece)
    @turn = next_turn
    @turn_number += 0.5
    @draw_moves += 1
    @draw_moves = 0 if @pawn_move || @piece_taken
  end

  def double_step?(start, piece)
    true if piece.is_a?(Pawn) && [start[1] + 2, start[1] - 2].include?(piece.rank)
  end

  def update_en_passant(start, piece) # rubocop:disable Metrics/AbcSize
    left_piece = piece_at([piece.file_left, piece.rank])
    right_piece = piece_at([piece.file_right, piece.rank])
    if left_piece.is_a?(Pawn) && left_piece&.color != piece.color ||
       right_piece.is_a?(Pawn) && right_piece&.color != piece.color
      @en_passant = [piece.file, (piece.rank + start[1]) / 2].join('')
    end
  end
end
