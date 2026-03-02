# frozen_string_literal: true

module Admin
  class JobsController < ApplicationController
    before_action :require_developer!

    def index
      @scheduled_jobs = SolidQueue::ScheduledExecution.order(scheduled_at: :desc).limit(20)
      @ready_jobs     = SolidQueue::ReadyExecution.order(created_at: :desc).limit(20)
      @failed_jobs    = SolidQueue::FailedExecution.order(created_at: :desc).limit(20)
    end

    def trigger
      location_id = params[:location_id].presence || ENV.fetch('DEFAULT_LOCATION_ID', 1)
      WeeklyShiftGenerationJob.perform_later(location_id)
      redirect_to admin_jobs_path, notice: 'Weekly shift generation job enqueued'
    end

    private

    def require_developer!
      redirect_to root_path, alert: 'Not allowed' unless current_user.developer_user?
    end
  end
end
