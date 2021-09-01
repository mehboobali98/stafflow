class EventsController < ApplicationController
  before_action :set_event_for_edit, only: %i[edit]
  before_action :set_event, only: %i[show update destroy]

  def display_calendar
    @events = Event.all
  end

  def index
    @events = Event.all
  end

  def show; end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      flash[:notice] = 'Event created successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = 'Unable to create event'
      render :new
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      flash[:notice] = 'Event updated successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = 'Unable to update event'
      render :edit
    end
  end

  def destroy
    @event.destroy
    flash[:notice] = 'Event deleted successfully'
    redirect_to action: 'index'
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_event_for_edit
    @event = Event.find(params[:id])
    @event.set_start_date_str
    @event.set_start_time_str
  end

  def event_params
    params.require(:event).permit(:name, :start_date_str, :start_time_str)
  end
end
