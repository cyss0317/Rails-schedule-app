# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  helper_method :save_return_to

  # before_action :set_time_zone, if: :user_signed_in?

  protected

  # def set_time_zone
  #   Time.zone = Time.zone.name
  # end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name middle_name last_name color phone email])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name middle_name last_name color phone email])
  end

  private

  def save_return_to
    session[:return_to] = request.fullpath
  end
end
