# frozen_string_literal: true

# module for chess inputs and outputs
module InputOutput
  def player_move
    loop do
      put_board
      puts 'Check.' if check?
      puts "#{@turn == 'w' ? 'White' : 'Black'} to move."
      move = gets.chomp
      return decipher(move)
    rescue StandardError => e
      puts "Error: #{e.message}. Please try again."
      sleep(0.5)
    end
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

  def put_board # rubocop:disable Metrics/AbcSize
    8.downto(1) do |n|
      puts "#{board['a'][n]}#{board['b'][n]}#{board['c'][n]}#{board['d'][n]}#{board['e'][n]}#{board['f'][n]}#{board['g'][n]}#{board['h'][n]} #{n}" # rubocop:disable Layout/LineLength
    end
    puts ' a  b  c  d  e  f  g  h'
  end

  def winner
    puts "Check mate! #{@turn == 'b' ? 'White' : 'Black'} player wins!"
  end

  def stalemate
    puts "It's a stalemate! #{@turn == 'w' ? 'White' : 'Black'} player has no possible moves!"
  end

  def draw
    puts "It's a draw! There have been 50 consecutive moves without a capture or pawn move."
  end

  private

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
