# frozen_string_literal: true

# Events Controller
class EventsController < ApplicationController
  before_action :authenticate_user!
  load_and_authorize_resource
  add_breadcrumb I18n.t('event.breadcrumbs.home'), :events_path

  # GET /events
  def index
    @events = @events.paginate(page: params[:page], per_page: PAGE_SIZE)
    respond_to do |format|
      format.html
    end
  end

  # GET /events/1
  def show
    add_breadcrumb t('event.breadcrumbs.edit'), :event_path
    respond_to do |format|
      format.html
    end
  end

  # GET /events/new
  def new
    add_breadcrumb t('event.breadcrumbs.new'), :new_event_path
    @event_date = params[:event_date]
    respond_to do |format|
      format.html
    end
  end

  # POST /events
  def create
    if @event.validate_event_year(event_params[:event_date])
      set_event(@event)
      is_saved = @event.save
    end
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to events_path, notice: t('event.messages.success.create_success')
        else
          flash.now[:error] = @event.errors.full_messages
          render :new, status: :unprocessable_content
        end
      end
    end
  end

  # GET /events/1/edit
  def edit
    add_breadcrumb t('event.breadcrumbs.edit'), :edit_event_path
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.validate_event_year(event_params[:event_date])
      set_event(@event)
      is_saved = @event.save
    end
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to events_path, notice: t('event.messages.success.update_success')
        else
          flash.now[:error] = @event.errors.full_messages
          render :edit, status: :unprocessable_content
        end
      end
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    respond_to do |format|
      format.html do
        if @event.destroyed?
          flash[:notice] = t('event.messages.success.delete_success')
        else
          flash[:error] = @event.errors.full_messages
        end
        redirect_to events_path
      end
    end
  end

  # GET /events/display_calendar
  def display_calendar
    add_breadcrumb t('event.breadcrumbs.display_calendar'), :display_calendar_events_path
    @start_date = event_calendar_start_date
    @events = @events.events_in_a_month(@start_date)
    respond_to do |format|
      format.html
    end
  end

  private

  def set_event(event)
    event.name = event_params[:name]
    event.starts_at = "#{event_params[:event_date]} #{event_params[:event_time]}"
  end

  def event_calendar_start_date
    return Date.today if params[:start_date].nil?

    Date.parse(params[:start_date])
  rescue Date::Error
    flash[:error] = t('event.simple_calendar.invalid_date')
  end

  def create_params
    params.require(:event).permit(:name)
  end

  def event_params
    params.require(:event).permit(:name, :event_date, :event_time)
  end
end
