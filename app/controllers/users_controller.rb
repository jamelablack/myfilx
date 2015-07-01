class UsersController < ApplicationController
before_filter :require_user, only: [:show]

	def new
		@user = User.new
	end

	def create
		@user = User.new(user_params)
		 if @user.save
		 	handle_invitations
      AppMailer.delay.send_welcome_email(@user.id)
		 	redirect_to sign_in_path, notice: "Congrats, you're now registered! Please sign in."
		 else
		 	flash[:notice] = "Something went wrong. Please try again."
		 	render :new
		 end
	end

	def show
		@user = User.find(params[:id])
	end

	def new_with_invitation_token
		invitation = Invitation.where(token: params[:token]).first
		if invitation
			@user = User.new(email: invitation.recipient_email)
			@invitation_token = invitation.token
	    render :new
	  else
	  	redirect_to expired_token_path
	  end
  end

	private
	def user_params
		params.require(:user).permit!
	end

	def handle_invitations
		if params[:invitation_token].present?
	 		invitation = Invitation.where(token: params[:invitation_token]).first
	 		@user.follow(invitation.inviter)
	 		invitation.inviter.follow(@user)
	 		invitation.update_column(:token, nil)
 		end
	end
end

