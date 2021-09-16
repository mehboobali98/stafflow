class NotificationsController < ApplicationController
  before_action :authenticate_user!

  # GET /notifications
  def fetch_user_notifications
    @notifications = current_user.notifications
    respond_to do |format|
      format.js
      format.html
    end
  end

  # POST /notifications/read
  def mark_notifications_as_read
    binding.pry
    Notification.where(recipient_id: current_user.id).where(status: Notification::STATUS[:unread])
                .where(id: params[:ids]).update_all(status: Notification::STATUS[:read])
    redirect_to notifications_path
  end
end
