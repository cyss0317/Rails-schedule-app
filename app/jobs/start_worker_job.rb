class StartWorkerJob < ApplicationJob
  queue_as :default

  def perform
    FlyWorkerService.start_worker
  end
end