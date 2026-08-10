# frozen_string_literal: true

require_relative '../lib/game'
describe Game do
  subject(:game) { described_class.new }

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

    context 'when move is en passant' do
      it 'removes the piece below if current player is white' do
        game = described_class.new('rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 1')
        pawn = game.piece_at(['e', 5])
        game.move(pawn.coord, ['d', 6])
        pieces = [game.piece_at(['d', 6])&.type, game.piece_at(['d', 5])&.type]
        expect(pieces).to eq(['pawn', nil])
      end

      it 'removes the piece above if current player is black' do
        game = described_class.new('rnbqkbnr/ppp1pppp/8/8/3pP3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1')
        pawn = game.piece_at(['d', 4])
        game.move(pawn.coord, ['e', 3])
        pieces = [game.piece_at(['e', 3])&.type, game.piece_at(['e', 4])&.type]
        expect(pieces).to eq(['pawn', nil])
      end
    end

    context 'when en passant value changes' do
      it 'sets it to the proper space' do
        game.square_at(['b', 5]).place_piece('P')
        game.move(['a', 7], ['a', 5])
        expect(game.en_passant).to eq('a6')
      end

      it 'sets it to "-" if no en passant' do
        game.instance_variable_set(:@en_passant, 'a3')
        game.move(['a', 2], ['a', 4])
        expect(game.en_passant).to eq('-')
      end
    end

    context 'when castle rights change' do
      let(:game) { described_class.new('rnbqkbnr/pppppppp/8/8/8/8/8/RNBQKBNR w KQkq - 0 1') }

      it 'removes queen side when queen side rook moves' do
        rook = game.piece_at(['a', 1])
        game.move(rook.coord, ['a', 2])
        expect(game.castle_rights).to eq('Kkq')
      end

      it 'removes king side when king side rook moves' do
        rook = game.piece_at(['h', 1])
        game.move(rook.coord, ['h', 2])
        expect(game.castle_rights).to eq('Qkq')
      end

      it 'removes both sides when king moves' do
        king = game.piece_at(['e', 1])
        game.move(king.coord, ['e', 2])
        expect(game.castle_rights).to eq('kq')
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
