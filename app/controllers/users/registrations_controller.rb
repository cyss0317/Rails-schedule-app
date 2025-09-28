# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    layout 'application'

    helper_method :assigned_color
    before_action :configure_sign_up_params, only: %i[create]
    before_action :configure_account_update_params, only: [:update]

    COLORS = [
      '#FFB6C1', # Light Pink
      '#AED581', # Light Green
      '#FFF176', # Lemon
      '#F48FB1', # Pink
      '#80CBC4', # Teal Green
      '#FFD180', # Light Orange
      '#B39DDB', # Lavender
      '#81D4FA', # Light Sky Blue
      '#FFAB91', # Peach
      '#C5E1A5', # Pale Green
      '#FFE082', # Light Mustard
      '#CE93D8', # Lilac
      '#90CAF9', # Soft Blue
      '#FFCCBC', # Salmon
      '#A5D6A7', # Mint
      '#FFF59D', # Pastel Yellow
      '#9FA8DA', # Periwinkle
      '#80DEEA', # Aqua
      '#E6EE9C', # Lime Yellow
      '#FFCDD2'  # Rose
    ].freeze

    # GET /resource/sign_up
    # def new
    #   super
    # end

    # POST /resource
    def create
      super do |user|
        loc_id = params[:location_id]

        next unless loc_id.present?

        location_user = LocationUser.find_or_create_by(user_id: user.id, location_id: loc_id, role: 'user')
        user.update(location_user_id: location_user.id)
      end
    end

    # GET /resource/edit
    # def edit
    #   super
    # end

    # PUT /resource
    # def update
    #   super
    # end

    # DELETE /resource
    # def destroy
    #   super
    # end

    # GET /resource/cancel
    # Forces the session data which is usually expired after sign
    # in to be expired now. This is useful if the user wants to
    # cancel oauth signing in/up in the middle of the process,
    # removing all OAuth session data.
    # def cancel
    #   super
    # end

    protected

    def assigned_color
      taken_colors = User.pluck(:color)
      available_colors = COLORS - taken_colors

      available_colors[0] || Faker::Color.hex_color
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      attributes = %i[last_name first_name middle_name color]
      # devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
      devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      attributes = %i[last_name first_name middle_name]
      devise_parameter_sanitizer.permit(:account_update, keys: attributes)
    end


    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
    def load_user
      @user ||= User.find_or_create_by
    end
  end
end
