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
    respond_to do |format|
      format.html
    end
  end

  # POST /events
  def create
    @event = Event.new
    binding.pry
    if validate_event_year
      set_event_fields(@event)
      is_saved = @event.save
      binding.pry
    else
      binding.pry
      respond_to do |format|
        format.html do
          if is_saved
            flash[:notice] = I18n.t('event.messages.success.create_success')
            redirect_to events_path
          else
            binding.pry
            flash.now[:errors] = @event.errors.full_messages
            render :new
          end
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
    set_event_fields(@event)
    is_saved = @event.save
    respond_to do |format|
      format.html do
        if is_saved
          flash[:notice] = I18n.t('event.messages.success.update_success')
          redirect_to events_path
        else
          flash.now[:errors] = @event.errors.full_messages
          render :edit
        end
      end
    end
  end

  # DELETE /events/1
  def destroy
    is_destroyed = @event.destroy
    respond_to do |format|
      format.html do
        if is_destroyed
          flash[:notice] = I18n.t('event.messages.success.delete_success')
        else
          flash[:errors] = I18n.t('event.messages.failure.delete_failure')
        end
        redirect_to events_path
      end
    end
  end

  # GET /events
  def display_calendar
    respond_to do |format|
      format.html
    end
  end

  private

  def set_event
    @event = Event.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:errors] = e.message
    redirect_to events_path
  end

  def set_events
    @events = Event.all
  end

  def set_event_fields(event)
    event.name = event_params[:name]
    event.starts_at = "#{event_params[:event_date]} #{event_params[:event_time]}"
  end

  def validate_event_year
    if Date.parse(event_params[:event_date]).year.to_s.length > 4
      binding.pry
      flash.now[:errors] = 'Event year cannot have more than 4 digits'
      false
    else
      true
    end
  rescue Date::Error => e
    flash[:errors] = e.message
  end

  def event_params
    params.require(:event).permit(:name, :event_date, :event_time)
  end
end
