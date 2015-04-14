class UsersController < ApplicationController
	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		 if @user.save
		 	redirect_to sign_in_path, notice: "Congrats, you're now registered! Please sign in."
		 else
		 	flash[:notcie] = "Something went wrong. Please try again."
		 	render :new
		 end
	end


	private
	def user_params
		params.require(:user).permit!
	end
end