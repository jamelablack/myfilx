class PasswordResetsController < ApplicationController
  def show
    user = User.where(token: params[:id]).first
    if user
      @token = user.token
    else
      redirect_to expired_token_path
    end
  end

  def create
    user = User.where(token: params[:token]).first
    if user
      PasswordReset.new(user, params[:password]).call
      flash[:success] = "Your password has been changed successfully."
      redirect_to sign_in_path
    else
      redirect_to expired_token_path
    end
  end
end
