# frozen_string_literal: true

require_relative '../lib/game'

describe Pawn do
  game = nil
  subject(:pawn) { game.piece_at(['a', 2]) }

  before do
    game = Game.new
  end

  describe '#valid_moves' do
    it 'returns an array of valid move arrays' do
      expect(pawn.valid_moves).to eq([['a', 3], ['a', 4]])
    end

    it 'includes valid takes' do
      game.board['b'][3].place_piece('p')
      expect(pawn.valid_moves).to include(['b', 3])
    end

    it 'does not include takes of your own pieces' do
      game.board['b'][3].place_piece('P')
      expect(pawn.valid_moves).not_to include(['b', 3])
    end

    it 'includes en passant' do
      game.instance_variable_set(:@en_passant, 'b3')
      expect(pawn.valid_moves).to include(['b', 3])
    end

    context 'when no argument is given' do
      it 'does not include moves that would leave current player in check' do
        game.square_at(['d', 2]).place_piece('p')
        expect(pawn.valid_moves).to eq([])
      end
    end

    context 'when (pre-check: true) argument is given' do
      it 'includes moves that would leave current player in check' do
        game.square_at(['d', 2]).place_piece('p')
        expect(pawn.valid_moves(pre_check: true)).to eq([['a', 3], ['a', 4]])
      end
    end
  end
end
