class Users::SessionsController < Devise::SessionsController
  def create
    params[:user][:remember_me] = '1'
    params[:user][:email]&.downcase!
    super
  end
end
