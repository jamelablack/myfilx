class Admin::VideosController < ApplicationController
  before_filter :require_user
  before_filter :require_admin


  def new
    @video = Video.new
  end

  def create
    video = Video.new(params[video_params])
    flash[:success] = "You have successfully added '#{video.title}'."
    redirect_to new_admin_video_path
  end

  private

  def video_params
    params.require(:video).permit!
  end

  def require_admin
    if !current_user.admin?
      flash[:error] = "You're not authorized to do that."
      redirect_to home_path
    end
  end
end
