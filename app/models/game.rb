# == Table Schema ==
#
# table name: games
#
# id                      :bigint       null: false, primary key
# white_player_id         :index        null:false, foreign key of 1 user
# color_player_id         :index                    foreign key of 1 user
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Game < ApplicationRecord
  # Callbacks
  after_create_commit do
    create_game_squares
    create_pawns
  end
  # Scopes
  # Validations
  validates_length_of :squares, maximum: 64

  # Associations
  #===Squares
  has_many :squares, dependent: :destroy
  #===Pieces
  has_many :pieces, through: :squares, source: :piece
  has_many :white_pieces, -> { merge(Piece.white_team) },
           through: :pieces, source: :game
  has_many :color_pieces, -> { merge(Piece.color_team) },
           through: :pieces, source: :game

  #===Users
  belongs_to :white_player, class_name: :User,
                            foreign_key: :white_player_id,
                            inverse_of: :white_games
  belongs_to :color_player, class_name: :User,
                            foreign_key: :color_player_id,
                            inverse_of: :color_games,
                            optional: true
  # Methods

  private

  def create_game_squares
    8.times do |r|
      8.times do |c|
        squares.create(column: c + 1, row: r + 1)
      end
    end
  end

  def create_pawns # STI cannot create through the square directly
    squares.where(row: 2).each do |square|
      Pawn.create(color: false, game: square.game, square: square)
    end
    squares.where(row: 7).each do |square|
      Pawn.create(color: true, game: square.game, square: square)
    end
  end
end
