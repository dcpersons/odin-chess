# frozen_string_literal: true

require_relative '../lib/game'

describe Pieces do
  describe '#illegal_check_move?' do
    it 'returns false if given move would not leave current player in check' do
      game = Game.new
      pawn = game.piece_at(['d', 2])
      expect(pawn.illegal_check_move?(['d', 3])).to be false
    end

    it 'returns true if given move would leave current player in check' do
      game = Game.new('rnb1kbnr/pppppppp/8/8/8/8/PPPPqPPP/RNBQKBNR w KQkq - 0 1')
      pawn = game.piece_at(['d', 2])
      expect(pawn.illegal_check_move?(['d', 3])).to be true
    end

    it 'properly returns false for castles' do
      game = Game.new('rnbqkbnr/pppp1ppp/8/8/8/2N5/PPP3PP/R3KBNR w KQkq - 0 1')
      king = game.piece_at(['e', 1])
      expect(king.illegal_check_move?(['O-O-O'])).to be false
    end

    it 'properly returns true for castles' do
      game = Game.new('1nbqkbnr/pppppppp/8/8/8/8/PPrPPPPP/R3KBNR w KQk - 0 1')
      king = game.piece_at(['e', 1])
      expect(king.illegal_check_move?(['O-O-O'])).to be true
    end
  end
end
