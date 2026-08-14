# frozen_string_literal: true

require_relative '../lib/game'

describe King do
  subject(:king) { game.piece_at(['e', 1]) }

  let(:game) { Game.new('rnbqkbnr/pppp1ppp/8/8/8/8/PPP3PP/RN2KBNR w KQkq - 0 1') }

  describe '#valid_moves' do
    it 'returns an array of valid move arrays' do
      expect(king.valid_moves).to include(['d', 1], ['d', 2], ['e', 2], ['f', 2])
    end

    it 'includes castles if available' do
      game.move(['b', 1], ['c', 3])
      expect(king.valid_moves).to include(['O-O-O'])
    end
  end

  describe '#castle_queenside' do
    it 'moves king from file E to C and rook from file A to D' do
      game.move(['b', 1], ['c', 3])
      king.castle_queenside
      pieces = [game.piece_at(['a', 1])&.type, game.piece_at(['b', 1])&.type, game.piece_at(['c', 1])&.type,
                game.piece_at(['d', 1])&.type, game.piece_at(['e', 1])&.type]
      expect(pieces).to eq([nil, nil, 'king', 'rook', nil])
    end
  end

  describe '#castle_kingside' do
    it 'moves king from file E to G and rook from file H to F' do # rubocop:disable RSpec/ExampleLength
      game.square_at(['f', 1]).piece = nil
      game.square_at(['g', 1]).piece = nil
      king.castle_kingside
      pieces = [game.piece_at(['e', 1])&.type, game.piece_at(['f', 1])&.type,
                game.piece_at(['g', 1])&.type, game.piece_at(['h', 1])&.type]
      expect(pieces).to eq([nil, 'rook', 'king', nil])
    end
  end
end
