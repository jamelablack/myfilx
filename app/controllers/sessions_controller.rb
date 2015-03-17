class SessionsController < ApplicationController
	def new
		redirect_to home_path if current_user
	end

	def create
		user = User.where(email: params[:email]).first
		if user && user.authenticate(params[:password])
			session[:user_id] = user.id
			redirect_to home_path, notice: "You're are signed in!"
		else
			flash[:notice] = "There is something wrong with your username or password."
			redirect_to sign_in_path
		end
	end


	def destroy
		session[:user_id] = nil
		redirect_to root_path, notice: "You've signed out."
	end
end