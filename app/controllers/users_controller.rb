class UsersController < ApplicationController
before_filter :require_user, only: [:show]

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		 if @user.save
		 	AppMailer.send_welcome_email(@user).deliver
		 	redirect_to sign_in_path, notice: "Congrats, you're now registered! Please sign in."
		 else
		 	flash[:notice] = "Something went wrong. Please try again."
		 	render :new
		 end
	end

	def show
		@user = User.find(params[:id])
	end



	private
	def user_params
		params.require(:user).permit!
	end
end
