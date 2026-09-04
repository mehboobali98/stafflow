class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_user
  load_and_authorize_resource

  # GET /notifications
  def index
    @status = params.fetch(:status, Notification::STATUS[:unread]).to_s
    @notifications = @notifications.read_status(@status).order(created_at: :desc)
                                   .paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
    end
  end

  # GET /notifications/count
  def count
    @count = @notifications.unread.size
    respond_to do |format|
      format.json { render json: @count }
    end
  end

  # POST /notifications/mark_as_read
  def mark_as_read
    @notifications.unread.where(id: params[:ids]).update_all(status: true)
    respond_to do |format|
      format.html { redirect_to notifications_url, notice: t('notifications.markedread') }
    end
  end

  private

  def authorize_user
    authorize! :read, current_user
  end
end
