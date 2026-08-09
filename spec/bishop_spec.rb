# frozen_string_literal: true

require_relative '../lib/game'
describe Bishop do
  game = nil
  subject(:bishop) { game.piece_at(['c', 4]) }

  before do
    game = Game.new('rnbqkbnr/ppp2ppp/3pp3/8/2B5/3PP3/PPP2PPP/RNBQK1NR w KQkq - 0 3')
  end

  describe '#valid_moves' do
    it 'returns an array of valid move arrays' do
      game.square_at(['b', 2]).instance_variable_set(:@piece, nil)
      expect(bishop.valid_moves).to include(['b', 5], ['a', 6], ['d', 5], ['e', 6], ['b', 3])
    end
  end
end
