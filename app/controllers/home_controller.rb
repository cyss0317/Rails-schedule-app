# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    current_user ? (redirect_to new_user_session_path) : (redirect_to new_user_registration_path)
  end
end
