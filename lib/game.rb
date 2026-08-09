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

  def piece_at(coord)
    raise 'Invalid coordinate' if board.dig(coord[0], coord[1]).nil?

    board.dig(coord[0], coord[1])&.piece
  end

  def square_at(coord)
    raise 'Invalid coordinate' if board.dig(coord[0], coord[1]).nil?

    board.dig(coord[0], coord[1])
  end

  def move(start, target)
    piece = piece_at(start)
    raise 'Invalid move' unless piece.valid_moves.include?(target)

    square_at(start).piece = nil
    square_at(target).place_piece(piece.to_letter)
  end

  def check?
    pieces = all_pieces
    king = pieces.find { |piece| piece.is_a?(King) && piece.color == @turn }
    pieces.any? { |piece| piece.valid_moves(pre_check: true).include?(king.coord) }
  end

  def all_pieces
    pieces = []
    board.each_value do |file|
      file.each do |square|
        pieces << square.piece unless square&.piece.nil?
      end
    end
    pieces
  end
end
