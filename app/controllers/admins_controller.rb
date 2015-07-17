class AdminsController < ApplicationController
  before_filter :require_admin

  Private

  def require_admin
    if !current_user.admin?
      flash[:error] = "You're not authorized to do that."
      redirect_to home_path
    end
  end
end
