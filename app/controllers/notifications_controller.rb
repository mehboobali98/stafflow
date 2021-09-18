class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
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
    @count = current_user.notifications.unread.size
    respond_to do |format|
      format.json { render json: @count }
    end
  end

  # POST /notifications/read
  def mark_as_read
    current_user.notifications.unread.where(id: params[:ids]).update_all(status: Notification::STATUS[:read])
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: t('notifications.markedread') }
    end
  end

  private

  def authorize_user
    authorize! :read, current_user
  end
end
