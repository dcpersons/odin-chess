# frozen_string_literal: true

require_relative 'lib/game'

loop do
  puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  puts 'New game (new)'
  puts 'Load game (load)'
  puts 'How to play (help)'
  puts 'Close game (exit)'
  puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
  response = gets.chomp.downcase
  game = Game.new
  case response
  when 'new'
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    puts 'Player vs. player (pvp)'
    puts 'Player vs. computer (cpu)'
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    game_mode = gets.chomp.downcase
    next game.cpu_game if game_mode == 'cpu'
    next game.play_game if game_mode == 'pvp'

    puts 'Invalid response.'
  when 'load'
    next puts 'No saved games found.' if Dir.children('./saves').empty?

    game = SaveLoad.load_game
    next game.play_game unless game.cpu
    next game.cpu_game if game.cpu
  when 'help'
    game.help
    next
  when 'exit'
    break
  else
    puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    puts 'Invalid response.'
    next sleep(0.5)
  end
end
