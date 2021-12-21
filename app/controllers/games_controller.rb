class GamesController < ApplicationController
  def index
    @games = Game.all
  end

  def show
    @game = Game.find(params[:id])
  end

  def create
    @game = current_user.white_games.new
    @game.color_player_id = sanitize_user_id
    @game.save
    redirect_to @game
  end

  def sanitize_user_id
    params[:user].to_i
  end
end
