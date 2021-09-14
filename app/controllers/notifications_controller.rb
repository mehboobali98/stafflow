class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def fetch_user_notifications
    @notifications = current_user.notifications
    respond_to do |format|
      format.js
    end
  end

  def notifications_count
    @count = current_user.notifications.length
    respond_to do |format|
      format.json { render json: @count }
    end
  end
end
