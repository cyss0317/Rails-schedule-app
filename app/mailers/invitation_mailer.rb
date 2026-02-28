# frozen_string_literal: true

class InvitationMailer < ApplicationMailer
  def invite(email:, location_id:, invited_by:)
    @sign_up_url = new_user_registration_url(location_id: location_id)
    @invited_by  = invited_by
    mail(to: email, subject: "You've been invited to join the schedule")
  end
end
