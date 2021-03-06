class UsersController < ApplicationController

  before_filter :authenticate_user!, :except => [:index, :show]
  before_filter :require_admin!, :except => [:index, :show]

  # GET /users
  # GET /users.xml
  def index
    @users = User.by_points.all

    @game_ids = Game.ids_for_history[0..-2]
    @users_by_name = User.by_name.all
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    @bets = @user.bets.all(:include => :game, :order => 'games.played_at ASC')
    @bonus_bets = @user.bonus_bets.all(:include => :bonus)

    @prev_user = @user.previous
    @next_user = @user.next

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end

  def destroy
    user = User.find(params[:id])
    user.destroy
    flash[:success] = "Usuário #{user.name} apagado!"
    redirect_to users_path
  end

  # POST /users/:id/ask_to_bet
  def ask_to_bet
    @user = User.find(params[:id])
    Resque.enqueue(MailJob, 'AdminMailer', 'deliver_ask_to_bet', {'user_id' => @user.id})
    flash[:notice] = "Email enviado."
    redirect_to user_path(@user)
  end

  # POST /users/:id/ask_for_payment
  def ask_for_payment
    @user = User.find(params[:id])
    Resque.enqueue(MailJob, 'AdminMailer', 'deliver_ask_for_payment', {'user_id' => @user.id})
    flash[:notice] = "Email enviado."
    redirect_to user_path(@user)
  end
  
end
