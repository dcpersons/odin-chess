# frozen_string_literal: true

require_relative '../lib/game'
describe InputOutput do
  subject(:game) { Game.new }

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
        expect(game.find_piece('P', ['a', 3]).coord).to eq(['a', 2])
      end

      it 'returns an error if there are are multiple matches' do
        game.square_at(['b', 3]).place_piece('p')
        expect { game.find_piece('P', ['b', 3]) }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when a letter, target, and file are given' do
      it 'returns the piece if there is only one match' do
        game.square_at(['b', 3]).place_piece('p')
        expect(game.find_piece('P', ['b', 3], 'a').coord).to eq(['a', 2])
      end

      it 'raises an error if there are multiple matches' do
        game.square_at(['a', 2]).place_piece('B')
        game.square_at(['a', 4]).place_piece('B')
        expect { game.find_piece('B', ['b', 3], 'a') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when a letter, target, and row are given' do
      it 'returns the piece if there is only one match' do
        game.square_at(['b', 5]).place_piece('N')
        expect(game.find_piece('N', ['a', 3], nil, 5).coord).to eq(['b', 5])
      end

      it 'raises an error if there are multiple matches' do
        game.square_at(['b', 3]).place_piece('p')
        expect { game.find_piece('P', ['b', 3], nil, 2).coord }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when letter, target, file, and row are given' do
      it 'returns the piece' do
        expect(game.find_piece('P', ['a', 3], 'a', 2).coord).to eq(['a', 2])
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
      expect(game.decipher('a7b8Q')).to include(['a', 7], ['b', 8, 'Q'])
    end

    it 'raises an error when moving a pawn to last rank and no promotion is specified' do
      game.square_at(['a', 7]).place_piece('P')
      expect { game.decipher('a7b8') }.to raise_error(StandardError, 'Unspecified promotion')
    end

    context 'when starting rank, starting file, and target are given' do
      it 'returns correct piece location and target arrays' do
        expect(game.decipher('a2a3')).to include(['a', 2], ['a', 3])
      end
    end

    context 'when given a target with no specified piece' do
      it 'infers piece is a pawn and returns the correct location and target arrays' do
        expect(game.decipher('a3')).to include(['a', 2], ['a', 3])
      end

      it 'raises an error when multiple pawns can move to target' do
        game.square_at(['b', 3]).place_piece('p')
        expect { game.decipher('b3') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when given a piece letter and target' do
      it 'returns the correct piece location and target arrays' do
        expect(game.decipher('Nc3')).to include(['b', 1], ['c', 3])
      end

      it 'raises and error when multiple of specified piece can move to target' do
        game.square_at(['b', 5]).place_piece('N')
        expect { game.decipher('Nc3') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when given a file and target' do
      it 'returns the correct piece location and target arrays' do
        game.square_at(['d', 1]).place_piece('N')
        expect(game.decipher('Nbc3')).to include(['b', 1], ['c', 3])
      end

      it 'raises an error when multiple of specified piece in file can move to target' do
        game.square_at(['b', 5]).place_piece('N')
        expect { game.decipher('Nbc3') }.to raise_error(StandardError, 'Unspecified piece')
      end
    end

    context 'when given a rank and target' do
      it 'returns correct piece location and target arrays' do
        game.square_at(['b', 5]).place_piece('N')
        expect(game.decipher('N1c3')).to include(['b', 1], ['c', 3])
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
        expect(game.decipher('O-O')).to include(['e', 1], ['O-O'])
      end
    end
  end
end
