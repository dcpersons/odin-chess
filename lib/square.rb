class Square
  attr_reader :coord, :column, :row
  attr_accessor :piece

  def initialize(column, row)
    @column = column
    @row = row
    @coord = column + row.to_s
    @piece = nil
  end

  def set_piece(letter)
    color = letter.match?(/[[:upper:]]/) ? 'white' : 'black'
    @piece = case letter.downcase
             when 'r'
               Rook.new(color, @column, @row)
             when 'n'
               Knight.new(color, @column, @row)
             when 'b'
               Bishop.new(color, @column, @row)
             when 'q'
               Queen.new(color, @column, @row)
             when 'k'
               King.new(color, @column, @row)
             when 'p'
               Pawn.new(color, @column, @row)
             end
  end
end
