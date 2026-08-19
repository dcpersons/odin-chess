# frozen_string_literal: true

# module for chess inputs and outputs
module InputOutput # rubocop:disable Metrics/ModuleLength
  def player_move # rubocop:disable Metrics/MethodLength
    loop do
      put_board
      puts "#{@turn == 'w' ? 'White' : 'Black'} to move. (Player)"
      puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
      move = gets.chomp
      return save if move.downcase == 'save'

      return decipher(move)
    rescue StandardError => e
      puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
      puts "Error: #{e.message}. Please try again."
      puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
      sleep(0.5)
    end
  end

  def cpu_move
    put_board
    puts "#{@turn == 'w' ? 'White' : 'Black'} to move. (CPU)"
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    sleep(1)
    pieces = find_pieces
    pieces.delete_if { |piece| piece.valid_moves.empty? }
    piece = pieces.sample
    move = piece.valid_moves.sample
    @input = if [['O-O-O'], ['O-O']].include?(move)
               move[0].to_s
             else
               "#{piece.to_letter.upcase unless piece.is_a?(Pawn)}#{piece.coord.join}#{'x' if piece_at(move)}#{move.join}"
             end
    [piece.coord, move]
  end

  # breaks down player given string and calls #find_piece on it
  # returns two coordinate arrays for #move and sets @input to later add to @history
  def decipher(input) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
    if ['O-O-O', 'O-O'].include?(input.upcase)
      piece = find_piece('K', [input.upcase])
      target = [input.upcase]
      @input = input.upcase
    else
      move = input.split('') - ['x']
      letter = %w[R N B Q K P].include?(move[0]) ? move.shift : 'P'
      promotion = move.pop if %w[R N B Q].include?(move.last)
      target = [move.delete_at(-2), move.pop.to_i, promotion].compact
      file = move.shift if move[0].to_i.zero?
      rank = move.shift&.to_i
      piece = find_piece(letter, target, file, rank)
      @input = "#{letter unless letter == 'P'}#{file}#{rank}#{'x' if piece_at(target)}#{target.join}"

    end
    [piece.coord, target]
  end

  # Returns a piece if enough disambiguators are given
  # Raises an error if no valid piece/move
  # Raises an error if not enough disambiguators
  def find_piece(letter, target = nil, file = nil, rank = nil) # rubocop:disable Metrics/CyclomaticComplexity
    pieces = find_pieces.select do |piece|
      piece.to_letter.upcase == letter &&
        (file.nil? || piece.file == file) &&
        (rank.nil? || piece.rank == rank) &&
        (target.nil? || piece.valid_moves.include?(target))
    end
    check_errors(pieces, letter, target)
    pieces.pop
  end

  def put_board(no_check: false) # rubocop:disable Metrics/AbcSize
    8.downto(1) do |n|
      puts "#{board['a'][n]}#{board['b'][n]}#{board['c'][n]}#{board['d'][n]}#{board['e'][n]}#{board['f'][n]}#{board['g'][n]}#{board['h'][n]} #{n}" # rubocop:disable Layout/LineLength
    end
    puts ' a  b  c  d  e  f  g  h'
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    return unless no_check || check?

    puts ' - Check -'
  end

  def help # rubocop:disable Metrics/MethodLength
    puts <<~TEXT
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      Moves are taken with standard algebraic notation without need to specify
        takes, checks, or checkmates.
      A target (space you want to move to) is always required unless castling.
      Prepend your move with a capital letter to specify which piece you want to
        move (not necessary for pawns).
      When a piece and target are not enough information, add a rank and/or file
        (between your piece and target) as a disambiguator.
      Append a capital letter to the end of your move when promoting a pawn.

      At any point, save your game by typing "save".
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      Would you like examples of valid and invalid inputs?(y/n)
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    TEXT
    examples if gets.chomp.downcase == 'y'
  end

  def finish(cause) # rubocop:disable Metrics/MethodLength
    put_board(no_check: true)
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    case cause
    when :winner
      puts "Check mate! #{@turn == 'b' ? 'White' : 'Black'} player wins!"
    when :stalemate
      puts "It's a stalemate! #{@turn == 'w' ? 'White' : 'Black'} player has no possible moves!"
    when :draw
      puts "It's a draw! There were 50 consecutive moves without a capture or pawn move."
    when :recursion
      puts "It's a draw! This exact board state repeated three times."
    end
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    put_history
  end

  private

  def put_history # rubocop:disable Metrics/MethodLength
    loop do
      puts 'View history? (y/n)'
      response = gets.chomp.downcase
      if response == 'y'
        @history.each_slice(2) do |move1, move2|
          puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~'
          puts "#{@history.index(move1) / 2 + 1}  #{move1.first}  #{move2&.first}"
        end
      end
      return if %w[y n].include?(response)

      puts 'Invalid response.'
    end
  end

  def examples
    examples_valid
    examples_invalid
  end

  def examples_valid # rubocop:disable Metrics/MethodLength
    puts <<~TEXT
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      Valid
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      d4 => pawn to d4
      Nc3 => knight to c3
      ed4 => pawn at file e to d4
      B3c5 => bishop at rank 3 to c5
      Ra1a6 => rook at a1 to a6
      c7c8Q => pawn at c7 to c8, promote to queen
      O-O-O => castle queenside (case insensitive)
      o-o => castle kingside (case insensitive)
    TEXT
  end

  def examples_invalid
    puts <<~TEXT
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      Invalid
      ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      b1c3 => knight needs to be specified (Nb1c3 is valid)
      e7e8 => promotion needs to be appended (e7e8Q is valid)
      R1d1 => invalid if both rooks are on rank 1 and can move do d1 (use file
        disambiguator in this case instead)
      Pe2e5 => invalid move (pawn cannot move 3 steps)
    TEXT
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
