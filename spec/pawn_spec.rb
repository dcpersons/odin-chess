# frozen_string_literal: true

require_relative '../lib/game'

describe Pawn do
  game = Game.new
  subject(:pawn) { game.board['a'][2].piece }
  describe '#valid_moves' do
    it 'returns an array of valid move arrays' do
      expect(pawn.valid_moves).to eq([['a', 3], ['a', 4]])
    end
  end
end
