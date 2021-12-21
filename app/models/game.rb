# == Table Schema ==
#
# table name: games
#
# id                      :bigint       null: false, primary key
# white_player_id         :index        null: false, foreign key of 1 user
# color_player_id         :index                     foreign key of 1 user
# game_over               :boolean                   default: false
# turn                    :boolean                   default: false
# winner_id               :index        null: true, foreign key of 1 user
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Game < ApplicationRecord
  # Callbacks
  after_update_commit do
    broadcast_update_later_to self, target: "chess_game_#{id}" unless created_at >= (5.seconds.ago)
  end

  after_create_commit do
    create_game_squares
    create_pawns(false, 2, white_player)
    create_back_row(false, 1, white_player)
    create_pawns(true, 7, color_player)
    create_back_row(true, 8, color_player)
  end
  # Scopes
  # Validations
  validates_length_of :squares, maximum: 64

  # Associations
  #===Pieces
  has_many :pieces, dependent: :destroy
  has_many :white_pieces, -> { merge(Piece.white_team) },
           class_name: :Piece,
           foreign_key: :game_id,
           dependent: :destroy
  has_many :color_pieces, -> { merge(Piece.color_team) },
           class_name: :Piece,
           foreign_key: :game_id,
           dependent: :destroy
  has_many :taken_pieces, -> { merge(Piece.taken_pieces) },
           class_name: :Piece,
           foreign_key: :game_id,
           dependent: :destroy
  #===Squares
  has_many :squares, -> { includes(:piece) }, dependent: :destroy
  #===Users
  belongs_to :white_player, class_name: :User,
                            foreign_key: :white_player_id,
                            inverse_of: :white_games
  belongs_to :color_player, class_name: :User,
                            foreign_key: :color_player_id,
                            inverse_of: :color_games,
                            optional: true
  belongs_to :winner, class_name: :User,
                      foreign_key: :winner_id,
                      inverse_of: :won_games,
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

  def create_pawns(color, row, user) # STI cannot create through the square directly
    squares.where(row: row).each do |square|
      Pawn.create(color: color, game: square.game, square: square, user: user)
    end
  end

  def create_back_row(color, row, user)
    row = squares.where(row: row)
    row.where(column: [1, 8]).each { |s| Rook.create(color: color, game: s.game, square: s, user: user) }
    row.where(column: [2, 7]).each { |s| Knight.create(color: color, game: s.game, square: s, user: user) }
    row.where(column: [3, 6]).each { |s| Bishop.create(color: color, game: s.game, square: s, user: user) }
    row.where(column: 4).each      { |s| Queen.create(color: color, game: s.game, square: s, user: user) }
    row.where(column: 5).each      { |s| King.create(color: color, game: s.game, square: s, user: user) }
  end
end
