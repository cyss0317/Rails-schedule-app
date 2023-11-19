# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, :set_time_zone, if: :devise_controller?

  protected

  def set_time_zone
    Time.zone = current_user.time_zone
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name middle_name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name middle_name last_name phone email])
  end
end
