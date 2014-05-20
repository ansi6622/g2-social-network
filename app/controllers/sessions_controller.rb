class SessionsController < ApplicationController
  def destroy
    session[:id] = nil
    redirect_to root_path, notice: "You have been logged out"
  end
end