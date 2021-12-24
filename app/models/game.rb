#=======================================|GAME TABLE SCHEMA|=======================================
#
# table name: games
#
# id                      :bigint       null: false, primary key
# white_player_id         :index        null: false, foreign key of 1 user
# color_player_id         :index                     foreign key of 1 user
# game_over               :boolean                   default: false
# turn                    :boolean                   default: false
# check                   :boolean                   default: false
# winner_id               :index        null: true, foreign key of 1 user
# draw_requestor_id       :index        null: true, foreign key of 1 user
# turns_count              :integer      counter_cache
# created_at              :datetime     null: false
# updated_at              :datetime     null: false
#
class Game < ApplicationRecord
  #=======================================|GAME CALLBACKS|=======================================
  after_touch do
    broadcast_update_later_to self, target: "chess_game_#{id}"
  end

  after_create_commit do
    create_game_squares
    create_pawns(false, 2, white_player)
    create_back_row(false, 1, white_player)
    create_pawns(true, 7, color_player)
    create_back_row(true, 8, color_player)
    create_chat
  end
  #=======================================|GAME VALIDATIONS|=======================================
  validates_length_of :squares, maximum: 64

  #=======================================|GAME ASSOCIATIONS|=======================================
  # ========|User related|======
  belongs_to :white_player, class_name: :User,
                            foreign_key: :white_player_id,
                            inverse_of: :white_games
  belongs_to :color_player, class_name: :User,
                            foreign_key: :color_player_id,
                            inverse_of: :color_games

  belongs_to :winner, class_name: :User,
                      foreign_key: :winner_id,
                      inverse_of: :won_games,
                      optional: true
  belongs_to :draw_requestor, class_name: :User,
                              foreign_key: :draw_requestor_id,
                              inverse_of: :requested_drawn_games,
                              optional: true

  # ========|Turn related|======
  has_many :turns, dependent: :destroy

  # ========|Piece related|======
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
  has_many :untaken_pieces, -> { merge(Piece.untaken_pieces) },
           class_name: :Piece,
           foreign_key: :game_id,
           dependent: :destroy
  # ========|Square related|======
  has_many :squares, -> { includes(:piece) }, dependent: :destroy

  # ========|Chat related|======
  has_one :chat, dependent: :destroy
  has_many :messages, through: :chat, class_name: :Message, source: :messages

  #=======================================|GAME METHODS|=====================================

  #=======================================|SCOPES|==========================================
  scope :recently_active, -> { where('updated_at > ?', Time.now - 30.minutes) }

  #=======================================|ATTRIBUTES|=======================================
  # To update the status of the game

  # User concedes a game, other user is winner
  def concede(user)
    update(game_over: true, winner: opposing_player_of_user(user))
    touch
  end

  # User wins a game. Could be DRY'd with above, but I prefer the semantic difference
  def declare_player_as_winner(player)
    update(game_over: true, winner: player)
    touch
  end

  # User requests a draw, other user can accept to set game as stalemate
  def request_draw_from(user)
    update(draw_requestor: user)
    touch
  end

  # Game is over, no winner is set.
  def declare_stalemate
    update(game_over: true, winner: nil)
    touch
  end

  # To find the opponent of a user
  def opposing_player_of_user(user)
    user == white_player ? color_player : white_player
  end

  #=======================================|FETCHES|=======================================
  # To collect information about the game relative to an input

  # The team in turn-dependent situations
  def current_team_live_pieces
    turn ? color_pieces.untaken_pieces : white_pieces.untaken_pieces
  end

  # The team's user in turn-dependent situations
  def current_player
    turn ? color_player : white_player
  end

  # The current team color in turn-dependent situations
  def current_color
    turn ? true : false
  end

  # The current team relative to a piece
  def team_of_piece(piece)
    piece.color ? color_pieces.untaken_pieces : white_pieces.untaken_pieces
  end

  # The current team relative to a piece, not discarding captured pieces
  def full_team_of_piece(piece)
    piece.color ? color_pieces : white_pieces
  end

  # The opposing team relative to a piece
  def opposing_team_of_piece(piece)
    piece.color ? white_pieces.untaken_pieces : color_pieces.untaken_pieces
  end

  # The castle square of the board relative to a king and direction
  def castle_square(king_square, direction)
    squares.find_by(row: king_square.row, column: king_square.column + direction)
  end

  # Kingside rook relative to a specific king
  def right_rook(king)
    full_team_of_piece(king).rook.first
  end

  # Queenside rook relative to a specific king
  def left_rook(king)
    full_team_of_piece(king).rook.last
  end

  # Queries a team if check can be prevented from checkmate
  def team_can_intercept_checkmate(team)
    team.each do |piece|
      return true if piece.attack_moves.any?(&:urgent?)
    end
    false
  end

  private

  #===========================================|GAME CREATION|==========================================
  # Sets up a new board of Chess!

  # Tiles of the game, 8x8 from left to right, bottom to top. (Row, Column)
  def create_game_squares
    1.upto(8) do |r|
      1.upto(8) { |c| squares.create(column: c, row: r) }
    end
  end

  def create_pawns(color, row, user)
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
