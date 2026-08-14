# frozen_string_literal: true

require_relative 'lib/game'

loop do
  puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  puts 'New game (new)'
  puts 'Load game (load)'
  puts 'How to play (help)'
  puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  response = gets.chomp.downcase
  game = Game.new
  case response
  when 'new'
    game.play_game
  when 'load'
    next puts 'No saved games found.' if Dir.children('./saves').empty?

    game = SaveLoad.load_game
    game.play_game
  when 'help'
    game.help
    next
  else
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    puts "Sorry, I didn't quite get that."
    next sleep(0.5)
  end
end
