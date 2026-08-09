# frozen_string_literal: true

require_relative '../lib/game'
describe Queen do
  game = nil
  subject(:queen) { game.piece_at(['d', 3]) }

  before do
    game = Game.new('rnb1kbnr/ppp1pppp/3q4/3p4/3P4/3Q4/PPP1PPPP/RNB1KBNR w KQkq - 2 3')
  end

  describe '#valid_moves' do
    it 'returns an array of valid move arrays' do
      expect(queen.valid_moves).to include(['a', 6], ['b', 5], ['h', 7], ['g', 6], ['a', 3], ['h', 3])
    end
  end
end
