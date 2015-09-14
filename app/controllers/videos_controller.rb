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
    if params[:query]
      @videos = Video.search(params[:query]).records.to_a
    else
      @videos = []
    end
  end
end
