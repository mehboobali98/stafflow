# frozen_string_literal: true

# Events Controller
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
      flash[:notice] = I18n.t 'event.messages.success.create_success'
      redirect_to action: 'index'
    else
      flash[:alert] = I18n.t 'event.messages.failure.create_failure'
      render :new
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      flash[:notice] = I18n.t 'event.messages.success.update_success'
      redirect_to action: 'index'
    else
      flash[:alert] = I18n.t 'event.messages.failure.update_failure'
      render :edit
    end
  end

  def destroy
    if @event.destroy
      flash[:notice] = I18n.t 'event.messages.success.delete_success'
    else
      flash[:alert] = I18n.t 'event.messages.failure.delete_failure'
    end
    redirect_to action: 'index'
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_event_for_edit
    @event = Event.find(params[:id])
    @event.set_start_date
    @event.set_start_time
  end

  def event_params
    params.require(:event).permit(:name, :event_start_date, :event_start_time)
  end
end
