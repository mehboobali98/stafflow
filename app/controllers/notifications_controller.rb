class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def fetch_user_notifications
    @notifications = current_user.notifications
    respond_to do |format|
      format.js
    end
  end
end
