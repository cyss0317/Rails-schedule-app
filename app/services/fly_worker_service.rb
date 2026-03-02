class FlyWorkerService
  APP_NAME = ENV['FLY_APP_NAME']
  MACHINE_ID = ENV['FLY_WORKER_MACHINE_ID']
  TOKEN = ENV['FLY_API_TOKEN']

  BASE_URL = 'https://api.machines.dev/v1/apps'

  def self.start_worker
    request(:post, 'start')
  end

  def self.stop_worker
    request(:post, 'stop')
  end

  def self.request(method, action)
    url = "#{BASE_URL}/#{APP_NAME}/machines/#{MACHINE_ID}/#{action}"

    Faraday.send(method, url) do |req|
      req.headers['Authorization'] = "Bearer #{TOKEN}"
      req.headers['Content-Type'] = 'application/json'
    end
  end
end
