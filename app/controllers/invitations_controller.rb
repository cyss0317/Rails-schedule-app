# frozen_string_literal: true

class InvitationsController < ApplicationController
  before_action :require_admin!

  def create
    email = params[:email].to_s.strip

    if email.blank?
      return redirect_back fallback_location: root_path, alert: 'Email is required'
    end

    InvitationMailer.invite(
      email: email,
      location_id: params[:location_id],
      invited_by: current_user.full_name
    ).deliver_now

    redirect_back fallback_location: root_path, notice: "Invitation sent to #{email}"
  end

  private

  def require_admin!
    return if current_user.admin_user? || current_user.developer_user?

    redirect_to root_path, alert: 'Not allowed'
  end
end
