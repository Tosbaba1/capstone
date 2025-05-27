class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :username, :avatar, :banner, :bio])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :username, :avatar, :banner, :bio])
  end

  def update_resource(resource, params)
    params.delete(:current_password)
    resource.update_without_password(params)
  end
end
