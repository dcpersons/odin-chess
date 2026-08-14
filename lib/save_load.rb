# frozen_string_literal: true

# module for chess saving and loading
module SaveLoad
  def self.load_game
    loaded = choose_save
    game = YAML.load_file("./saves/#{loaded}.yml")
    Game.new(game[:fen], game[:history])
  end

  def self.choose_save
    loaded = loop do
      puts 'Which game would you like to load?'
      Dir.children('./saves').each { |filename| puts filename.split('.').first }
      return loaded if Dir.children('./saves').include?("#{loaded = gets.chomp.downcase}.yml")

      puts 'File not found.'
    end
  end

  def save
    puts 'What would you like your save to be called?'
    name = gets.chomp.downcase
    file = File.new("saves/#{name}.yml", 'w')
    file.write(YAML.dump({
                           fen: to_fen,
                           history: @history
                         }))
    file.fsync
    :saved
  end
end
