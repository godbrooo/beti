# == Schema Information
#
# Table name: bets
#
#  id         :bigint(8)        not null, primary key
#  challenger :boolean
#  status     :integer          default("pending")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  game_id    :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_bets_on_game_id  (game_id)
#  index_bets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (game_id => games.id)
#  fk_rails_...  (user_id => users.id)
#

class Bet < ApplicationRecord
  belongs_to :game

  belongs_to :user, optional: true
  enum status: [ :pending, :ongoing, :closed]

end
