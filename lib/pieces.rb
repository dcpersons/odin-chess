class Pieces
  attr_reader :color, :column, :row, :coord

  def initialize(color, column, row)
    @color = color
    @column = column
    @row = row
    @coord = column + row.to_s
  end

  def type
    self.class::TYPE
  end

  def to_letter
    letter = type[0]
    return letter.upcase if color == 'white'

    letter
  end
end

Dir.glob('lib/pieces/**.rb') { |name| require_relative "../#{name}" }
