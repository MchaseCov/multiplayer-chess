class UsersController < ApplicationController
  def index
    @users = User.recently_online
  end
end
