class UsersController < ApplicationController
  before_action :is_user_logged_in?, only: [:index]

  def index
    @users = User.all_except(session[:id])
    @graph = Graph.new
    @current_user = current_user
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(
      first_name: params[:user][:first_name],
      last_name: params[:user][:last_name],
      email: params[:user][:email],
      password: params[:user][:password],
      password_confirmation: params[:user][:password_confirmation]
    )
    if @user.save
      @user.send_confirmation_email
      redirect_to root_path, notice: "Please check your email for a confirmation"
    else
      render 'users/new'
    end
  end

  def show
    @user = current_user
  end

  private

  def is_user_logged_in?
    unless current_user
      redirect_to root_path, notice: "Please login"
    end
  end

end