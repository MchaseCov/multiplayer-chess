require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include TestModelValidations
  # test_validates_presence_of
  # test_validates_uniqueness_of
  #
  test 'Users playing white games have white pieces' do
    assert users(:first_user).white_pieces
  end
  test 'Users playing color games have color pieces' do
    assert users(:first_user).color_pieces
  end
end
