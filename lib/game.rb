# frozen_string_literal: true

require_relative 'square'
require_relative 'pieces'
require_relative 'board'

# class for creating Games of chess
class Game
  attr_reader :board, :turn, :castle_rights, :en_passant, :draw_moves, :turn_number

  include Board

  def initialize(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1')
    @board = make_board
    setup_game(fen)
  end

  def play_game
    loop do
      move = player_move
      begin
        move(move[1], move[0])
        return winner if check_mate?
        return draw if stalemate?
      rescue StandardError => e
        puts "Error: #{e.message}"
      end
    end
  end

  def player_move
    until move
      put_board
      puts "#{@turn == 'w' ? 'White' : 'Black'} to move."
      move = gets.chomp
    end
  end

  def move(start, target)
    piece = piece_at(start)
    raise(StandardError, 'Invalid move') unless piece.valid_moves.include?(target)

    if target == ['O-O-O'] then castle_queenside
    elsif target == ['O-O'] then castle_queenside
    else
      en_passant_take(target, piece.color) if en_passant == target.join && piece_at(start).is_a?(Pawn)
      square_at(start).piece = nil
      square_at(target).place_piece(piece.to_letter)
    end
    update_variables(start, piece_at(target), piece.castle_value)
  end

  def check?
    pieces = find_pieces
    king = pieces.find { |piece| piece.instance_of?(King) && piece.color == @turn }
    pieces.any? { |piece| piece.valid_moves(pre_check: true).include?(king.coord) }
  end

  def find_pieces
    pieces = []
    @board.each_value do |file|
      file.each do |square|
        pieces << square.piece unless square&.piece.nil? || square.piece.color == @turn && !square.piece.is_a?(King)
      end
    end
    pieces
  end

  def en_passant_take(target, color)
    if color == 'w'
      square_at([target[0], target[1] - 1]).piece = nil
    else
      square_at([target[0], target[1] + 1]).piece = nil
    end
  end

  private

  def update_variables(start, piece, castle_value)
    update_castle_rights(castle_value)
    @en_passant = '-'
    update_en_passant(start, piece) if [start[1] + 2, start[1] - 2].include?(piece.rank) && piece.is_a?(Pawn)
  end

  def update_castle_rights(castle_value)
    @castle_rights.delete!(castle_value)
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
