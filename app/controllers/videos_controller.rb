class VideosController < ApplicationController
	before_filter :require_user

	def index
		@videos = Video.all
		@categories = Category.all
	end

	def show
		@video = VideoDecorator.decorate(Video.find(params[:id]))
		@reviews = @video.reviews
	end

	def search
		@results = Video.search_by_title(params[:search_term])
	end

  def advanced_search
    options = {
    reviews: params[:reviews],
    rating_from: params[:rating_from],
    rating_to: params[:rating_to]
  }
    if params[:query]
      @videos = Video.search(params[:query], options).records.to_a
    else
      @videos = []
    end
  end
end
