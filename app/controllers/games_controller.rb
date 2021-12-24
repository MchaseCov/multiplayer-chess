class GamesController < ApplicationController
  before_action :authorize_game_participant, only: %i[concede request_draw]
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

  def concede
    @game = Game.find(params[:game_id])

    @game.concede(current_user)
  end

  def request_draw
    if !@game.draw_requestor
      @game.request_draw_from(current_user)
    elsif @game.draw_requestor == @game.opposing_player_of_user(current_user)
      @game.declare_stalemate
    end
  end

  private

  def sanitize_user_id
    params[:user].to_i
  end

  def authorize_game_participant
    @game = Game.find(params[:game_id])
    return unless current_user == (@game.white_player || @game.color_player)
    return if @game.game_over
  end
end
