# frozen_string_literal: true

require_relative 'square'
require_relative 'pieces'
require_relative 'board'

# class for creating Games of chess
class Game
  attr_reader :board, :turn, :castle_rights, :en_passant, :draw_moves, :turn_number
  attr_writer :pawn_move, :piece_taken

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

  def move(start, target, promotion = nil, no_update: false)
    piece = piece_at(start)

    if target == ['O-O-O'] then piece.castle_queenside
    elsif target == ['O-O'] then piece.castle_kingside
    else standard_move(piece, target, promotion)
    end
    update_variables(start, target, piece.castle_value) unless no_update
  end

  def check?
    pieces = find_pieces(next_turn)
    king = find_piece('K')
    pieces.any? { |piece| piece.valid_moves(pre_check: true).any? { |move| move & king.coord == king.coord } }
  end

  def en_passant_take(target)
    square_at([target[0], turn == 'w' ? target[1] - 1 : target[1] + 1]).piece = nil
  end

  # turns player given string into array and calls #find_piece on it
  # returns two coordinate arrays for #move
  def decipher(move) # rubocop:disable Metrics/AbcSize
    return [find_piece('K').coord, [move.upcase]] if ['O-O-O', 'O-O'].include?(move.upcase)

    move = move.split('')
    letter = %w[R N B Q K P].include?(move[0]) ? move.shift : 'P'
    promotion = move.pop if %w[R N B Q].include?(move.last)
    target = [move.delete_at(-2), move.pop.to_i, promotion].compact
    file = move.shift if move[0].to_i.zero?
    rank = move.shift&.to_i

    piece = find_piece(letter, file, rank, target)

    [piece.coord, target]
  end

  def find_pieces(color = @turn)
    pieces = []
    @board.each_value do |file|
      file.each { |square| pieces << square.piece unless square&.piece.nil? }
    end
    pieces.keep_if { |piece| piece.color == color }
  end

  # Returns a piece if enough disambiguators are given
  # Raises an error if no valid piece/move
  # Raises an error if not enough disambiguators
  def find_piece(letter, file = nil, rank = nil, target = nil) # rubocop:disable Metrics/CyclomaticComplexity
    pieces = find_pieces.select do |piece|
      piece.to_letter.upcase == letter &&
        (file.nil? || piece.file == file) &&
        (rank.nil? || piece.rank == rank) &&
        (target.nil? || piece.valid_moves.include?(target))
    end
    check_errors(pieces, letter, target)
    pieces.pop
  end

  private

  def standard_move(piece, target, promotion)
    promotion = promotion&.downcase if piece.color == 'b'
    self.piece_taken = !empty_space?(target)
    en_passant_take(target) if en_passant == target.join && piece.is_a?(Pawn)
    square_at(piece.coord).piece = nil
    square_at(target).place_piece(promotion || piece.to_letter)
  end

  def next_turn
    @turn == 'w' ? 'b' : 'w'
  end

  def update_variables(start, target, castle_value)
    piece = piece_at(target)
    @castle_rights.delete!(castle_value)
    @en_passant = '-'
    update_en_passant(start, piece) if piece.double_step?(start)
    @turn_number += 1 if @turn == 'b'
    @draw_moves += 1
    @draw_moves = 0 if @pawn_move || @piece_taken || check?
    @turn = next_turn
  end

  def update_en_passant(start, piece) # rubocop:disable Metrics/AbcSize
    left_piece = piece_at([piece.file_left, piece.rank])
    right_piece = piece_at([piece.file_right, piece.rank])
    if left_piece.is_a?(Pawn) && other_color?(left_piece.coord) ||
       right_piece.is_a?(Pawn) && other_color?(right_piece.coord)
      @en_passant = [piece.file, turn == 'w' ? start[1] + 1 : start[1] - 1].join('')
    end
  end

  def check_errors(piece, letter, target)
    raise(StandardError, 'Unspecified promotion') if unspecified_promotion?(letter, target)
    raise(StandardError, 'Invalid move') if piece.empty?
    raise(StandardError, 'Unspecified piece') if piece.length > 1
  end

  def unspecified_promotion?(letter, move)
    letter == 'P' && move&.length == 2 &&
      (@turn == 'w' && move[1] == 8 || @turn == 'b' && move[1] == 1)
  end
end
