class ConfirmationsController < ApplicationController

  def unconfirmed_registration
    @user = User.find params[:id]
  end

  def send_confirmation_email
    user = User.find params[:id]
    UserMailer.welcome_email(user).deliver
    redirect_to root_path, notice: "Email has been sent to #{user.email}. Please check your email to confirm"
  end

  def update
    user = User.find params[:id]
    user.confirm_user
    redirect_to '/sessions/new', notice: "Your email has been confirmed. You can now log in"
  end

  def confirm_friendships
    SocialGraph.new(User.find(params[:friend_id])).confirm_friendship(params[:requestor_id])
    redirect_to users_path
  end

end
