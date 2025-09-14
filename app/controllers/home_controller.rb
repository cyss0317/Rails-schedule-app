# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    Rails.logger.info "ip address: #{request.remote_ip}"
    Rails.logger.info "X-Forwarded-For: #{request.headers['X-Forwarded-For']}"
    Rails.logger.info "HTTP_X_REAL_IP: #{request.headers['HTTP_X_REAL_IP']}"
    return redirect_to(new_user_session_path) unless current_user

    # current_user ? render : (redirect_to new_user_session_path and return)
    current_user ? (redirect_to companies_path and return) : (redirect_to new_user_session_path and return)
    # render the company controller#index
    # render the location#index and let user choose and redirect to the meetings
    # based on the location id
    start_date = params.fetch(:start_date, Date.today).to_date
    location_id = params['location_id']

    # if location_id.blank?
    #   flash.now[]
    # end
    @meetings = Meeting.filter_by_location_id(location_id).monthly_meetings(start_date)
  end
end
