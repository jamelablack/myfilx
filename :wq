class PasswordReset
  attr_accessor :user, :password

  def initialize(user, password)
    @user = user
    @password = password
  end

  def call
    user.password = password
    user.generate_token
    user.save
  end

end
