class MyBetsController < ApplicationController
  
  before_filter :authenticate_user!
  
  # GET /my_bet
  def show
    @user = current_user
    
    suborder = params[:desc] ? 'DESC' : 'ASC'
    conditions = params[:empty] ? ['games.id NOT IN (?)', @user.bets.all(:select => 'game_id').map(&:game_id)] : nil
    
    @games = Game.all(
      :order => "played_at #{suborder}", 
      :conditions => conditions
    )

    respond_to do |format|
      format.html # show.html.erb
    end
  end

end

