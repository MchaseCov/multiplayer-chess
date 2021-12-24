require 'test_helper'

class PieceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'pieces belong to a square' do
    assert pieces(:white_rook).square
  end
  test 'pieces belong to a game' do
    assert pieces(:white_rook).game
  end
  test 'pieces have valid moves' do
    pieces.each do |piece|
      assert piece.valid_moves
    end
  end
  test 'starting back row cannot move at start' do
    %i[white_rook white_bishop white_queen white_king
       color_rook color_bishop color_queen color_king].each do |piece|
      assert pieces(piece).valid_moves.blank?
    end
  end
  test 'Knight and Pawn can move at start' do
    %i[white_pawn_1 color_pawn_1 white_knight color_knight].each do |piece|
      assert pieces(piece).valid_moves.present?
    end
  end

  test 'A checkmated king has no valid moves' do
    assert pieces(:checked_king).valid_moves.blank?
  end
end
