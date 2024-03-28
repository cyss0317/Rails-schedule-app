# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    layout 'application'

    before_action :configure_sign_up_params, only: %i[new create]
    before_action :configure_account_update_params, only: [:update]

    COLORS = ['#8C6E63',
              '#546E7A',
              '#7E57C2',
              '#FFA726',
              '#689F38',
              '#FF4081',
              '#4FC3F7',
              '#E040FB',
              '#9CCC65',
              '#FF7043',
              '#29B6F6',
              '#FFD54F']

    # GET /resource/sign_up
    def new
      super
    end

    # POST /resource
    # def create
    #   super
    # end

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

    # If you have extra params to permit, append them to the sanitizer.
    def configure_sign_up_params
      attributes = %i[last_name first_name middle_name]
      devise_parameter_sanitizer.permit(:sign_up, keys: attributes)
    end

    # If you have extra params to permit, append them to the sanitizer.
    def configure_account_update_params
      attributes = %i[last_name first_name middle_name]
      devise_parameter_sanitizer.permit(:account_update, keys: attributes)
    end

    def sign_up_params
      attributes = %i[last_name first_name middle_name color email password password_confirmation]

      update_color

      params.require(:user).permit(attributes)
    end

    def update_color
      taken_colors = User.pluck(:color)
      available_colors = COLORS.map { |color| color unless taken_colors.include?(color) }.compact

      params[:user][:color] = available_colors[0]
    end

    # The path used after sign up.
    # def after_sign_up_path_for(resource)
    #   super(resource)
    # end

    # The path used after sign up for inactive accounts.
    # def after_inactive_sign_up_path_for(resource)
    #   super(resource)
    # end
  end
end
