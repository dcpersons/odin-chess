# frozen_string_literal: true

require_relative '../lib/game'
describe Knight do
  game = nil
  subject(:knight) { game.piece_at(['c', 3]) }

  describe '#valid_moves' do
    it 'returns an array of valid move arrays' do
      game = Game.new('r1bqkbnr/pppppppp/8/3n4/8/2N5/PPPPPPPP/R1BQKBNR w KQkq - 6 4')
      expect(knight.valid_moves).to include(['a', 4], ['e', 4], ['b', 5], ['d', 5], ['b', 1])
    end

    it 'does not include moves that would leave current player in check' do
      game = Game.new('r1bqkbnr/pppppppp/8/8/8/2N2n2/PPPPPPPP/R1BQKBNR w Kkq - 14 8')
      expect(knight.valid_moves).to eq([])
    end
  end
end
