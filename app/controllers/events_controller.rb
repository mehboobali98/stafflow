class EventsController < ApplicationController
  before_action :set_product_for_edit, only: %i[edit]
  before_action :set_prodct, only: %i[show update destroy]

  def display_calendar
    @events = Event.all
  end

  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to @event
    else
      render :new
    end
  end

  def edit; end

  def update
    @event = Event.find(params[:id])
    if @event.update(event_params)
      redirect_to @event
    else
      render :edit
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy

    redirect_to root_path
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_event_for_update
    @event = Event.find(params[:id])
    @event.start_date_str = Event.convert_to_date(@event.start_time)
    @event.start_time_str = Event.convert_to_time(@event.start_time)
    @event.end_date_str = Event.convert_to_date(@event.end_time)
    @event.end_time_str = Event.convert_to_time(@event.end_time)
  end

  def event_params
    params.require(:event).permit(:name, :start_date_str, :start_time_str, :end_date_str, :end_time_str)
  end
end
