# frozen_string_literal: true

require_relative '../lib/game'

describe Pawn do
  game = Game.new
  subject(:pawn) { game.board['a'][2].piece }
  describe '#valid_moves' do
    it 'returns an array of valid move arrays' do
      expect(pawn.valid_moves).to eq([['a', 3], ['a', 4]])
    end

    it 'includes valid takes' do
      game.board['b'][3].setup_piece('p')
      expect(pawn.valid_moves).to include(['b', 3])
    end

    it 'includes en passant' do
      game.board['b'][2].instance_variable_set(:@piece, Pawn.new('black', 'b', 2, game))
      game.instance_variable_set(:@en_passant, 'b3')
      expect(pawn.valid_moves).to include(['b', 3])
    end

    it 'does not include takes of your own pieces' do
      game.board['b'][3].setup_piece('P')
      expect(pawn.valid_moves).not_to include(['b', 3])
    end
  end
end
