class Admin::VideosController < AdminsController
  def new
    @video = Video.new
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      flash[:success] = "You have successfully added '#{@video.title}'."
      redirect_to new_admin_video_path
    else
      flash[:error] = "Your video was not added properly."
      render :new
    end
  end

  private

  def video_params
    params.require(:video).permit(:title, :small_cover, :large_cover, :description, :category_id, :video_url)
  end
end
