class LocationUsersController < ApplicationController
  before_action :load_location_users, only: %i[index]
  before_action :load_location_user, only: %i[toggle_active]
  def index
    render
  end

  def update
    new_role = @location_user.admin? ? :user : :admin
    @location_user.update!(role: new_role)

    respond_to do |format|
      format.turbo_stream # renders update.turbo_stream.erb
      format.html { redirect_back fallback_location: location_users_path, notice: "Role updated to #{new_role}" }
    end
  end

  def toggle_active
    @location_user.update(active: !@location_user.active)

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def load_location_users
    @location_users = LocationUser.where(location_id: params[:location_id])
  end

  def load_location_user
    @location_user = LocationUser.find(params[:id])
  end
end
