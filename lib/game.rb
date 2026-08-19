# frozen_string_literal: true

require_relative 'square'
require_relative 'pieces'
require_relative 'board'
require_relative 'input_output'
require_relative 'save_load'
require 'colorize'
require 'yaml'

# class for creating Games of chess
class Game
  attr_reader :board, :turn, :castle_rights, :en_passant, :draw_moves, :turn_number, :cpu
  attr_writer :pawn_move, :piece_taken

  include InputOutput
  include Board
  include SaveLoad

  def initialize(fen = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1', history = [], cpu = nil)
    @board = make_board
    @history = history
    @cpu_turn = cpu
    setup_game(fen)
  end

  def play_game
    loop do
      move = @turn == @cpu_turn ? cpu_move : player_move
      break if move == :saved

      move(move[0], move[1])
      update_variables(move[0], move[1])
      break finish(:winner) if check_mate?
      break finish(:stalemate) if no_moves?
      break finish(:draw) if @draw_moves == 50
      break finish(:recursion) if recursion?
    end
  end

  def cpu_game
    @cpu_turn = %w[w b].sample
    play_game
  end

  def move(start, target)
    piece = piece_at(start)

    return piece.castle_queenside if target == ['O-O-O']
    return piece.castle_kingside if target == ['O-O']

    if target.length > 2
      promotion = target.pop
      promotion.downcase! if piece.color == 'b'
    end
    standard_move(piece, target, promotion)
  end

  def update_variables(start, target)
    piece = piece_at(target)
    @history << [@input]
    @castle_rights = @castle_rights.delete(@moved)
    @en_passant = '-'
    update_en_passant(start, piece) if piece&.double_step?(start)
    @turn_number += 1 if @turn == 'b'
    @draw_moves += 1
    @draw_moves = 0 if @pawn_move || @piece_taken
    @turn = next_turn
    @history.last << "#{board_to_fen} #{variables_to_fen(history: true)}"
  end

  def check?
    pieces = find_pieces(next_turn)
    king = find_piece('K')
    pieces.any? { |piece| piece.valid_moves(pre_check: true).any? { |move| move & king.coord == king.coord } }
  end

  def check_mate?
    no_moves? && check?
  end

  def no_moves?
    pieces = find_pieces
    pieces.none? { |piece| !piece.valid_moves.empty? }
  end

  def recursion?
    @history.count { |event| event[1] == @history.last.last } == 3
  end

  def en_passant_take(target)
    square_at([target[0], turn == 'w' ? target[1] - 1 : target[1] + 1]).piece = nil
  end

  def find_pieces(color = @turn)
    pieces = []
    @board.each_value do |file|
      file.each { |square| pieces << square.piece unless square&.piece.nil? }
    end
    pieces.keep_if { |piece| piece.color == color }
  end

  def move_info(piece, target)
    @piece_taken = !empty_space?(target)
    @moved = "#{piece.castle_value}#{piece_at(target)&.castle_value}"
    @pawn_move = piece.is_a?(Pawn)
  end

  private

  def standard_move(piece, target, promotion)
    move_info(piece, target)
    en_passant_take(target) if en_passant == target.join && piece.is_a?(Pawn)
    square_at(piece.coord).piece = nil
    square_at(target).place_piece(promotion || piece.to_letter)
  end

  def next_turn
    @turn == 'w' ? 'b' : 'w'
  end

  def update_en_passant(start, piece) # rubocop:disable Metrics/AbcSize
    left_piece = piece_at([piece.file_left, piece.rank])
    right_piece = piece_at([piece.file_right, piece.rank])
    if left_piece.is_a?(Pawn) && other_color?(left_piece.coord) ||
       right_piece.is_a?(Pawn) && other_color?(right_piece.coord)
      @en_passant = [piece.file, turn == 'w' ? start[1] + 1 : start[1] - 1].join('')
    end
  end
end
