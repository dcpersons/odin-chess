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

    it 'returns nil if an invalid coordinate is given' do
      expect(game.square_at(['a', 0])).to be_nil
    end
  end

  describe '#square_at' do
    it 'returns the square at given coordinate array' do
      expect(game.square_at(['a', 2])).to be_a(Square)
    end

    it 'returns nil if invalid coordinate is given' do
      expect(game.square_at(['z', 0])).to be_nil
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

    context 'when promoting a pawn' do
      it 'moves and promotes pawn if promotion is specified' do
        game.square_at(['a', 7]).place_piece('P')
        game.move(['a', 7], ['b', 8, 'Q'])
        expect(game.piece_at(['b', 8])).to be_a(Queen)
      end
    end
  end

  describe '#update_variables' do
    context 'when game variables update' do
      let(:game) { described_class.new('rnbqkbnr/pppppppp/8/8/8/8/8/RNBQKBNR w KQkq - 0 1') }

      it 'removes queen side when queen side rook moves' do
        rook = game.piece_at(['a', 1])
        game.move(rook.coord, ['a', 2])
        game.update_variables(rook.coord, ['a', 2])
        expect(game.castle_rights).to eq('Kkq')
      end

      it 'removes king side when king side rook moves' do
        rook = game.piece_at(['h', 1])
        game.move(rook.coord, ['h', 2])
        game.update_variables(rook.coord, ['h', 2])
        expect(game.castle_rights).to eq('Qkq')
      end

      it 'removes both sides when king moves' do
        king = game.piece_at(['e', 1])
        game.move(king.coord, ['e', 2])
        game.update_variables(king.coord, ['e', 2])
        expect(game.castle_rights).to eq('kq')
      end

      it 'increments stalemate move counter when a non-pawn moves without taking' do
        king = game.piece_at(['e', 1])
        game.move(king.coord, ['e', 2])
        expect { game.update_variables(king.coord, ['e', 2]) }.to change(game, :draw_moves).by(1)
      end

      it 'resets stalemate move counter to 0 when a pawn moves' do
        game.move(['e', 1], ['e', 2])
        game.update_variables(['e', 1], ['e', 2])
        game.move(['e', 7], ['e', 6])
        expect { game.update_variables(['e', 7], ['e', 6]) }.to change(game, :draw_moves).to(0)
      end

      it 'resets stalemate move counter to 0 when a piece is taken' do
        rook = game.piece_at(['h', 1])
        game.move(rook.coord, ['h', 7])
        expect { game.update_variables(rook.coord, ['h', 7]) }.not_to change(game, :draw_moves)
      end

      it 'resets stalemate move counter to 0 when a pawn is moved and promoted' do
        game = described_class.new('1nbqkbnr/Pppppppp/8/8/8/8/1PPPPPPP/RNBQKBNR w KQk - 10 11')
        game.move(['a', 7], ['a', 8, 'Q'])
        expect { game.update_variables(['a', 7], ['a', 8]) }.to change(game, :draw_moves).to(0)
      end

      it 'increments turn counter on black moves' do
        game.move(['e', 1], ['e', 2])
        game.update_variables(['e', 1], ['e', 2])
        game.move(['a', 7], ['a', 6])
        expect { game.update_variables(['a', 7], ['a', 6]) }.to change(game, :turn_number).to(2)
      end

      it 'does not increment turn counter on white moves' do
        game.move(['a', 1], ['a', 2])
        expect { game.update_variables(['a', 1], ['a', 2]) }.not_to change(game, :turn_number)
      end

      it 'changes turn variable to opposite color' do
        king = game.piece_at(['e', 1])
        game.move(king.coord, ['e', 2])
        expect { game.update_variables(king.coord, ['e', 2]) }.to change(game, :turn).to('b')
      end
    end

    context 'when en passant value changes' do
      it 'sets it to the proper space' do
        game.square_at(['b', 4]).place_piece('p')
        game.move(['a', 2], ['a', 4])
        game.update_variables(['a', 2], ['a', 4])
        expect(game.en_passant).to eq('a3')
      end

      it 'sets it to "-" if no en passant' do
        game.instance_variable_set(:@en_passant, 'a3')
        game.move(['a', 2], ['a', 4])
        game.update_variables(['a', 2], ['a', 4])
        expect(game.en_passant).to eq('-')
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

  describe '#no_moves?' do
    it 'returns true if current player has no valid moves' do
      game = described_class.new('rnbqkbnr/ppp1pppp/3K4/8/3q4/8/PPPP1PPP/RNBQ1BNR w kq - 0 1')
      expect(game.no_moves?).to be true
    end

    it 'returns false if current player has a valid move' do
      expect(game.no_moves?).to be false
    end
  end

  describe '#check_mate?' do
    it 'returns true if current player is in check mate' do
      game = described_class.new('rnbqkbnr/ppp1pppp/3K4/8/3q4/8/PPPP1PPP/RNBQ1BNR w kq - 0 1')
      expect(game.check_mate?).to be true
    end

    it 'returns false if current player is in check but not check mate' do
      game = described_class.new('rnb1kbnr/pppppppp/8/8/8/8/PPPPqPPP/RNBQKBNR w KQkq - 0 1')
      expect(game.check_mate?).to be false
    end

    it 'returns false if current player is not in check and has no valid moves' do
      game = described_class.new('K6k/2q5/8/8/8/8/8/8 w - - 0 1')
      expect(game.check_mate?).to be false
    end
  end
end
