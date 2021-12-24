require 'test_helper'

# 5 x 5 Test board
# 1-25
# +---------+
# |COLOR TM |
# |R|B|Q|K|N|21-25
# |P|P|P|P|P|16-20
# |_|_|_|_|_|11-15
# |P|P|P|P|P|6-10
# |N|K|Q|B|R|1-5
# |WHITE TM |
# +---------+

# 3x3 check board
# 26-34
# K IS WHITE, ELSE COLOR
# +-----+
# |R|_|B|
# |_|_|_|
# |K|_|Q|
# +-----+

class SquareTest < ActiveSupport::TestCase
  include TestModelValidations
  test_validates_presence_of :row, :column

  test 'Chessboard 25 squares save' do
    assert squares.find_all(&:save)
  end
  test 'Board must be 8x8 at most' do
    [0, 9].each do |i|
      assert_not Square.new(row: 1, column: i).save
      assert_not Square.new(row: i, column: 1).save
    end
  end
end
