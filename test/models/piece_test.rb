require 'test_helper'

class PieceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'pieces belong to a square' do
    assert pieces(:one).square
  end
  test 'pieces belong to a game' do
    assert pieces(:one).game
  end
end
