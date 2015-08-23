class UserSignup

  attr_accessor :error_message, :user

  def initialize(user)
    @user = user
  end

  def sign_up(stripe_token, invitation_token)
    self.stripe_token = stripe_token
    self.invitation_token = invitation_token

    handle_invalid and return self if user.invalid?

    if customer.successful?
      user.customer_token = customer.customer_token
      user.save
      handle_invitations(invitation_token)
      AppMailer.delay.send_welcome_email(user.id)
      self.status = :success
    else
      handle_failure(customer.error_message)
    end

    self
  end

  def successful?
    status == :success
  end

  private

  attr_accessor :status, :customer, :stripe_token, :invitation_token

  def customer
    @customer ||= StripeWrapper::Customer.create(
      :user => user,
      :card => stripe_token,
    )
  end

  def handle_failure(message)
    self.status = :failed
    self.error_message = message
  end

  def handle_invalid
    handle_failure("Your user info is invalid. Please see errors below.")
  end

  def handle_invitations(invitation_token)
    if invitation_token.present?
      invitation = Invitation.where(token: invitation_token).first
      user.follow(invitation.inviter)
      invitation.inviter.follow(user)
      invitation.update_column(:token, nil)
    end
  end
end

