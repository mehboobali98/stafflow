# Events Controller
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update destroy]
  before_action :set_events, only: %i[index display_calendar]

  # GET /events
  def index
    respond_to do |format|
      format.html
    end
  end

  # GET /events/1
  def show
    respond_to do |format|
      format.html
    end
  end

  # GET /events/new
  def new
    @event = Event.new
    @event_date = params[:event_date]
    respond_to do |format|
      format.html
    end
  end

  # POST /events
  def create
    @event = Event.new
    if @event.validate_event_year(event_date)
      set_event_fields(@event)
      is_saved = @event.save
    end
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to events_path, notice: t('event.messages.success.create_success')
        else
          flash.now[:error] = @event.errors.full_messages
          render :new
        end
      end
    end
  end

  # GET /events/1/edit
  def edit
    respond_to do |format|
      format.html
    end
  end

  # PATCH/PUT /events/1
  def update
    if @event.validate_event_year(event_date)
      set_event_fields(@event)
      is_saved = @event.save
    end
    respond_to do |format|
      format.html do
        if is_saved
          redirect_to events_path, notice: t('event.messages.success.update_success')
        else
          flash.now[:error] = @event.errors.full_messages
          render :edit
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
    @start_date = event_calendar_start_date
    @events = @events.events_in_a_month(@start_date)
    respond_to do |format|
      format.html
      format.js
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = t('event.messages.error.event_not_found')
    redirect_to events_path
  end

  def set_events
    @events = Event.all
  end

  def set_event_fields(event)
    event.name = event_params[:name]
    event.starts_at = "#{event_params[:event_date]} #{event_params[:event_time]}"
  end

  def event_calendar_start_date
    return Date.today if params[:start_date].nil?

    Date.parse(params[:start_date])
  rescue Date::Error
    flash[:error] = t('event.simple_calendar.invalid_date')
  end

  def event_params
    params.require(:event).permit(:name, :event_date, :event_time)
  end

  def event_date
    event_params[:event_date]
  end
end
