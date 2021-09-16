class NotificationsController < ApplicationController
  before_action :authenticate_user!
  PAGE_SIZE = 2 # Temporary line

  # GET /notifications
  def fetch_user_notifications
    respond_to do |format|
      format.js do
        @notifications = current_user.notifications.read_status(params[:status])
                                     .paginate(page: params[:page], per_page: PAGE_SIZE)
      end
      format.html do
        @notifications = current_user.notifications.unread.paginate(page: params[:page], per_page: PAGE_SIZE)
      end
    end
  end

  # GET /notifications/count
  def notifications_count
    @count = current_user.notifications.unread.length
    respond_to do |format|
      format.json { render json: @count }
    end
  end

  # POST /notifications/read
  def mark_notifications_as_read
    Notification.where(recipient_id: current_user.id).unread.where(id: params[:ids])
                .update_all(status: Notification::STATUS[:read])
    redirect_to notifications_url
  end
end
