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
  def show; end

  # GET /events/new
  def new
    @event = Event.new
  end

  # POST /events
  def create
    @event = Event.new
    @event.set_event_fields(event_params)
    respond_to do |format|
      if @event.save
        format.html do
          flash[:notice] = I18n.t('event.messages.success.create_success')
          redirect_to action: 'index'
        end
      else
        format.html do
          flash[:errors] = @event.errors.full_messages
          render :new
        end
      end
    end
  end

  # GET /events/1/edit
  def edit; end

  # PATCH/PUT /events/1
  def update
    @event.set_event_fields(event_params)
    respond_to do |format|
      if @event.save
        format.html do
          redirect_to action: 'index'
          flash[:notice] = I18n.t('event.messages.success.update_success')
        end
      else
        format.html do
          flash[:errors] = @event.errors.full_messages
          render :edit
        end
      end
    end
  end

  # DELETE /events/1
  def destroy
    respond_to do |format|
      if @event.destroy
        format.html do
          flash[:notice] = I18n.t('event.messages.success.delete_success')
          redirect_to action: 'index'
        end
      else
        format.html { redirect_to action: 'index', errors: I18n.t('event.messages.failure.delete_failure') }
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
    redirect_to action: 'index'
  end

  def set_events
    @events = Event.all
  end

  def event_params
    params.require(:event).permit(:name, :event_date, :event_time)
  end
end
