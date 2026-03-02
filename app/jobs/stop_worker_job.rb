class StopWorkerJob < ApplicationJob
  queue_as :default

  def perform
    FlyWorkerService.stop_worker
  end
end