class BetsController < ApplicationController
  def index
    @bets_pending = current_user.bets.pending
    @bets_ongoing = current_user.bets.ongoing
    @bets_closed = current_user.bets.closed


  end
  def show
    @bet = Bet.find(params[:id])
  end
end
