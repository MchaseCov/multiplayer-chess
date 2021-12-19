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
  test 'Games do not need a color piece player to be created' do
    assert_not games(:no_players).color_player
  end
end
