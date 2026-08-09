# frozen_string_literal: true

require_relative '../lib/game'
describe Rook do
  game = nil
  subject(:rook) { game.piece_at(['a', 3]) }

  before do
    game = Game.new('1nbqkbnr/1ppppppp/r7/p7/P7/R7/1PPPPPPP/1NBQKBNR w Kk - 2 3')
  end

  describe '#valid_moves' do
    it 'retruns an array of valid move arrays' do
      expect(rook.valid_moves).to include(['a', 1], ['a', 2], ['b', 3], ['c', 3], ['d', 3])
    end
  end
end
