# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    Rails.logger.info "ip address: #{request.remote_ip}"
    Rails.logger.info "X-Forwarded-For: #{request.headers['X-Forwarded-For']}"
    Rails.logger.info "HTTP_X_REAL_IP: #{request.headers['HTTP_X_REAL_IP']}"

    params.fetch(:start_date, Date.today).to_date
    @meetings = Meeting.current_week_meetings
    current_user ? render : (redirect_to new_user_session_path)
  end
end
