class ChatsController < ApplicationController
  def show
    @game = Game.find(params[:game_id])
    @chat = @game.chat
  end
end
