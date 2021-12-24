require 'test_helper'

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test 'Games belong to a white piece player' do
    assert games(:one).white_player
  end
  test 'Games belong to a color piece player' do
    assert games(:one).color_player
  end
  test 'Games have pieces' do
    assert games(:one).pieces
  end
  test 'Games have white pieces' do
    assert games(:one).white_pieces
  end
  test 'Games have color pieces' do
    assert games(:one).color_pieces
  end
end
