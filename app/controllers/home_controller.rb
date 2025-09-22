# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    Rails.logger.info "ip address: #{request.remote_ip}"
    Rails.logger.info "X-Forwarded-For: #{request.headers['X-Forwarded-For']}"
    Rails.logger.info "HTTP_X_REAL_IP: #{request.headers['HTTP_X_REAL_IP']}"
    return redirect_to(new_user_session_path) unless current_user

    if current_user.admin_user? && current_user.companies.empty?
      flash[:notice] = "Let's setup your company first"
      redirect_to new_company_path(user_id: current_user.id)
      # elsif current_user.active_user? && current_user.working_companies.empty?
      # direct user to the location user new path
      # redirect_to company_locations_path(company_id: current_user.companies.first.id) and return
    else
      company_id = current_user.companies&.first&.id || current_user.working_companies&.first&.id
      redirect_to company_locations_path(company_id:) and return
    end
  end
end
