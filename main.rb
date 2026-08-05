require_relative 'lib/game'
game = Game.new
square = Square.new('a', 1, game)
square.setup_piece('p')
