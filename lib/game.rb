require_relative 'square'
require_relative 'pieces'

class Game
  def initialize
    @board = { 'a' => Array.new(9) { Square.new }, 'b' => Array.new(9) { Square.new },
               'c' => Array.new(9) { Square.new }, 'd' => Array.new(9) { Square.new },
               'e' => Array.new(9) { Square.new }, 'f' => Array.new(9) { Square.new },
               'g' => Array.new(9) { Square.new }, 'h' => Array.new(9) { Square.new } }
    @board.each { |column| column[0] = nil }
  end
end
