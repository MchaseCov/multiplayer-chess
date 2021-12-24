class MessagesController < ApplicationController
  before_action :set_game_and_chat

  def new
    @message = @chat.messages.new
  end

  def create
    @message = @chat.messages.new(message_params)
    @message.author = current_user
    respond_to do |format|
      if @message.save
        format.turbo_stream
      else flash[:alert] = 'Message failed to send.'
      end
      format.html { redirect_to @game }
    end
  end

  private

  def set_game_and_chat
    @game = Game.find(params[:game_id])
    @chat = @game.chat
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
