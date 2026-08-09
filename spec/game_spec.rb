# frozen_string_literal: true

require_relative '../lib/game'
describe Game do
  subject(:game) { Game.new }

  describe '#piece_at' do
    it 'returns the piece at given coordinate array' do
      piece = [game.piece_at(['a', 2]).type, game.piece_at(['a', 2]).color]
      expect(piece).to eq(%w[pawn w])
    end

    it 'returns nil if there is no piece' do
      expect(game.piece_at(['a', 3])).to be_nil
    end

    it 'raises an error if an invalid coordinate is given' do
      expect { game.square_at(['a', 0]) }.to raise_error('Invalid coordinate')
    end
  end

  describe '#square_at' do
    it 'returns the square at given coordinate array' do
      expect(game.square_at(['a', 2])).to be_a(Square)
    end

    it 'raises an error if an invalid coordinate is given' do
      expect { game.square_at(['a', 0]) }.to raise_error('Invalid coordinate')
    end
  end

  describe '#move' do
    context 'when the move is valid' do
      it 'moves piece from one coordinate array to another' do
        game.move(['a', 2], ['a', 4])
        aggregate_failures do
          expect(game.piece_at(['a', 2])).to be_nil
          expect(game.piece_at(['a', 4])).to be_a(Pawn)
        end
      end

      it 'replaces the piece at the target location' do
        game.square_at(['b', 3]).place_piece('q')
        expect { game.move(['a', 2], ['b', 3]) }.to change { game.piece_at(['b', 3]).type }.from('queen').to('pawn')
      end
    end

    context 'when an invalid move is given' do
      it 'raises an error if piece is incapable of that move' do
        expect { game.move(['a', 2], ['b', 6]) }.to raise_error('Invalid move')
      end

      it 'raises an error if it would leave current player in check' do
        game.square_at(['d', 2]).place_piece('p')
        expect { game.move(['a', 2], ['a', 3]) }.to raise_error('Invalid move')
      end
    end
  end

  describe '#check?' do
    it 'returns true if current player king is in check' do
      game.square_at(['d', 2]).place_piece('p')
      expect(game.check?).to be true
    end

    it 'returns false if current player king is not in check' do
      game.square_at(['e', 2]).place_piece('p')
      expect(game.check?).to be false
    end
  end
end
