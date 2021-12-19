class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def show
    @game = Game.where(id: params[:id]).includes({ squares: :piece }, :pieces).first
  end

  def create
    current_user.white_games.create
  end
end
