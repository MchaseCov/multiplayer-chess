require 'test_helper'

class SquareTest < ActiveSupport::TestCase
  include TestModelValidations
  test_validates_presence_of :row, :column

  test 'Row/col can be between 1 and 8' do
    assert squares(:one).save
  end
  test 'row cannot be above 8 or less than 1' do
    assert_not Square.new(row: 0, column: 9).save
  end
end
