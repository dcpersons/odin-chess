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

    context 'when game variables update' do
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

      it 'increments stalemate move counter when a non-pawn moves without taking' do
        king = game.piece_at(['e', 1])
        expect { game.move(king.coord, ['e', 2]) }.to change(game, :draw_moves).by(1)
      end

      it 'resets stalemate move counter to 0 when a pawn moves' do
        king = game.piece_at(['e', 1])
        pawn = game.piece_at(['e', 7])
        game.move(king.coord, ['e', 2])
        expect { game.move(pawn.coord, ['e', 6]) }.to change(game, :draw_moves).to(0)
      end

      it 'resets stalemate move counter to 0 when a piece is taken' do
        rook = game.piece_at(['h', 1])
        expect { game.move(rook.coord, ['h', 7]) }.not_to change(game, :draw_moves)
      end

      it 'increments the turn counter by 0.5' do
        king = game.piece_at(['e', 1])
        expect { game.move(king.coord, ['e', 2]) }.to change(game, :turn_number).to(1.5)
      end

      it 'changes turn variable to opposite color' do
        king = game.piece_at(['e', 1])
        expect { game.move(king.coord, ['e', 2]) }.to change(game, :turn).to('b')
      end
    end

    context 'when promoting a pawn' do
      it 'moves and promotes pawn if promotion is specified' do
        game.square_at(['a', 7]).place_piece('P')
        game.move(['a', 7], ['b', 8], 'Q')
        expect(game.piece_at(['b', 8])).to be_a(Queen)
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

  describe '#find_piece' do
    context 'when a letter is given with no target' do
      it 'returns the piece if there is only one' do
        expect(game.find_piece('K')).to be_a(King)
      end

      it 'raises an error if there is more than one' do
        expect { game.find_piece('P') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when a letter and target are given' do
      it 'returns the piece if there is only one match' do
        expect(game.find_piece('P', nil, nil, ['a', 3]).coord).to eq(['a', 2])
      end

      it 'returns an error if there are are multiple matches' do
        game.square_at(['b', 3]).place_piece('p')
        expect { game.find_piece('P', nil, nil, ['b', 3]) }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when a letter, target, and file are given' do
      it 'returns the piece if there is only one match' do
        game.square_at(['b', 3]).place_piece('p')
        expect(game.find_piece('P', 'a', nil, ['b', 3]).coord).to eq(['a', 2])
      end

      it 'raises an error if there are multiple matches' do
        game.square_at(['a', 2]).place_piece('B')
        game.square_at(['a', 4]).place_piece('B')
        expect { game.find_piece('B', 'a', nil, ['b', 3]) }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when a letter, target, and row are given' do
      it 'returns the piece if there is only one match' do
        game.square_at(['b', 5]).place_piece('N')
        expect(game.find_piece('N', nil, 5, ['a', 3]).coord).to eq(['b', 5])
      end

      it 'raises an error if there are multiple matches' do
        game.square_at(['b', 3]).place_piece('p')
        expect { game.find_piece('P', nil, 2, ['b', 3]).coord }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when letter, target, file, and row are given' do
      it 'returns the piece' do
        expect(game.find_piece('P', 'a', 2, ['a', 3]).coord).to eq(['a', 2])
      end
    end
  end

  describe '#decipher' do
    it 'raises an error if no piece at location' do
      expect { game.decipher('a3a4') }.to raise_error(StandardError, 'Invalid move')
    end

    it 'raises an error if piece at location cannot perform move to target' do
      expect { game.decipher('a2a5') }.to raise_error(StandardError, 'Invalid move')
    end

    it 'requires an addition letter at the end when promoting a pawn' do
      game.square_at(['a', 7]).place_piece('P')
      expect(game.decipher('a7b8Q')).to eq([['a', 7], ['b', 8, 'Q']])
    end

    it 'raises an error when moving a pawn to last rank and no promotion is specified' do
      game.square_at(['a', 7]).place_piece('P')
      expect { game.decipher('a7b8') }.to raise_error(StandardError, 'Unspecified promotion')
    end

    context 'when starting rank, starting file, and target are given' do
      it 'returns correct piece location and target arrays' do
        expect(game.decipher('a2a3')).to eq([['a', 2], ['a', 3]])
      end
    end

    context 'when given a target with no specified piece' do
      it 'infers piece is a pawn and returns the correct location and target arrays' do
        expect(game.decipher('a3')).to eq([['a', 2], ['a', 3]])
      end

      it 'raises an error when multiple pawns can move to target' do
        game.square_at(['b', 3]).place_piece('p')
        expect { game.decipher('b3') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when given a piece letter and target' do
      it 'returns the correct piece location and target arrays' do
        expect(game.decipher('Nc3')).to eq([['b', 1], ['c', 3]])
      end

      it 'raises and error when multiple of specified piece can move to target' do
        game.square_at(['b', 5]).place_piece('N')
        expect { game.decipher('Nc3') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when given a file and target' do
      it 'returns the correct piece location and target arrays' do
        game.square_at(['d', 1]).place_piece('N')
        expect(game.decipher('Nbc3')).to eq([['b', 1], ['c', 3]])
      end

      it 'raises an error when multiple of specified piece in file can move to target' do
        game.square_at(['b', 5]).place_piece('N')
        expect { game.decipher('Nbc3') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when given a rank and target' do
      it 'returns correct piece location and target arrays' do
        game.square_at(['b', 5]).place_piece('N')
        expect(game.decipher('N1c3')).to eq([['b', 1], ['c', 3]])
      end

      it 'raises an error when multiple of specified piece in row can move to target' do
        game.square_at(['d', 1]).place_piece('N')
        expect { game.decipher('N1c3') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when castle is called for' do
      it 'returns king location and castle symbol arrays' do
        game.square_at(['f', 1]).piece = nil
        game.square_at(['g', 1]).piece = nil
        expect(game.decipher('O-O')).to eq([['e', 1], ['O-O']])
      end
    end
  end
end
