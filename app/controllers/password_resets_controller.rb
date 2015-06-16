class PasswordResetsController < ApplicationController

  before_action :redirect_expired_token, only: [:show, :create]

  def show
    @token = user.token
  end

  def create
    PasswordReset.new(user, params[:password]).call
    flash[:success] = "Your password has been changed successfully."
    redirect_to sign_in_path
  end

  private

  def user
    @user ||= User.find_by(token: params[:id] || params[:token])
  end

  def redirect_expired_token
    redirect_to expired_token_path unless user
  end

end
