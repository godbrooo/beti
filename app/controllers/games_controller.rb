class GamesController < ApplicationController

  def index
    @games = Game.all.where(:user == current_user)
  end

  def new
    @game = Game.new
  end

  def create
  # binding.pry
    @game = Game.new(game_params)
    @bet = Bet.new
    @bet.user = current_user
    @bet.challenger = true
    @bet.game = @game
      if @game.save && @bet.save
       @bet.ongoing!
       redirect_to invite_path(@game)
      else
       render :new
      end
  end

  def ongoing
    @game.ongoing!
  end

  def closed
    @game.closed!
  end


def invite; end


  def save_invite
    @game = Game.find(params[:id])
    user_emails = params[:invitations][:users]
    success = true

    user_emails.each do |_key, email|
      user = User.find_by(email: email)
      if user
        UserMailer.invite(user, @game).deliver_now
      else
      user = User.invite!({email: email}, current_user)
      # user1 = User.invite_guest!(email: email, attributes: {game: @game, bet: bet} ,invited_by: current_user)
      end
      bet = Bet.new(user: user, game: @game, challenger: false)
      if bet.save
        bet.pending!
      else
        success = false
      end
    end

    if success
      bet = current_user.bets.find_by(game_id: @game.id)
      redirect_to bet_path(bet)
    else
      flash[:error] ="Les invitations ne se sont pas biens déroulées, veuillez recommencer"
      render :invite
    end
  end

  def show

    @game = Game.find(params[:id])
  end



  def winners
    bet = Bet.find(params[:id])
    @game = bet.game
    @game.prizes.build

    @ranking_possibilities = if @game.winner?
      [["Perdant", 0],["Gagnant", 1]]
    else
      # [0,1,2,3]
      [["Perdant", 0] ,["1er",1] ,["2nd",2], ["3ème", 3]]
    end
  end
  # raise


def close
  bet = Bet.find(params[:id])
  @game = bet.game
  if @game.update(game_params)
    @total_reward = (@game.bets.ongoing.count * @game.price).to_f
    success = true
    prizes = @game.prizes.where(ranking:(1..3))


    if @game.winner?
      prizes.each do |prize|
        prize.reward = @total_reward / prizes.count
        success = false unless prize.save
      end

    elsif @game.ranking?

        prizes.each do |prize|
          if prize.ranking == 1
            prize.reward = @total_reward * (0.5)
          elsif prize.ranking == 2
            prize.reward = @total_reward * (0.3)
          elsif prize.ranking == 3
            prize.reward = @total_reward * (0.2)
          end
          prize.save



        end
      #  premier_prix = @total_reward * (0.5)
      #  prizes.where(ranking: 1).first.reward = premier_prix.to_i

      #  second_prix = prizes.where(:ranking => 2)
      #  second_prix.first.reward = @total_reward * (0.2)
      #  prizes.where(:ranking => 2).first.reward = @total_reward * (0.2)

      # if prizes.where(:ranking => 3).exists?
      #  troisieme_prix = prizes.where(:ranking => 3)
      #  troisieme_prix.first.reward = @total_reward.to_f * (0.1)
      # end
    end
 # raise
    @game.closed!
    if success
      redirect_to resume_path
    else
      flash[:alert] = "Error during calculating rewards"
    render :winners
    end
  else
    flash[:alert] = "Error durring saving prizes"
    render :winners
  end
end
# @place.update_attributes(place_params)
# >>  params["game"][:prizes_attributes]["0"][:ranking]

def resume_challenge
  bet = Bet.find(params[:id])
  @game = bet.game
  @bets = @game.bets
  @prizes = @game.prizes
  @game.closed!
  @bets.each do |bet|
    bet.closed!

  end
  redirect_to bet_path(bet)
  # redirect_to bet_path(@bets.first)

end

# @place.update_attributes(place_params)
# >>  params["game"][:prizes_attributes]["0"][:ranking]

# def resume_challenge
#   @game = Game.find(params[:id])
#   @total_reward = @game.bet.ongoing.count * @game.price
#   @game.bet.ongoing.each do |beter|
#     beter.reward = @total_reward / (@game.prizes(WHERE ranking = 1))
#   end




private


def game_params
 params.require(:game).permit(:id, :title, :description, :price, :dead_line,:category,:status, :photo, prizes_attributes: [:ranking, :reward, :game, :user_id])
end


  def prize_params
    params.require(:prize).permit(:ranking, :reward, :game, :user)
  end

end


