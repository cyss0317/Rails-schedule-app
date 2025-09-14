# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    Rails.logger.info "ip address: #{request.remote_ip}"
    Rails.logger.info "X-Forwarded-For: #{request.headers['X-Forwarded-For']}"
    Rails.logger.info "HTTP_X_REAL_IP: #{request.headers['HTTP_X_REAL_IP']}"
    return redirect_to(new_user_session_path) unless current_user

    redirect_to company_locations_path(company_id: current_user.companies.first.id) and return
  end
end
