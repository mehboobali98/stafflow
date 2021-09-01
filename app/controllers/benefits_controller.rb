class BenefitsController < ApplicationController
  def index
    @benefit = Benefit.all
  end

  def new
    @benefit = Benefit.new
  end

  def show
    @benefit = Benefit.find(params[:id])
  end

  def update
    @benefit = Benefit.find(params[:id])
    if @benefit.update(benefit_arguments)
      flash[:notice] = 'Event Updated Successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = 'Unable to update event'
      redirect_back(fallback_location: root_path)

    end
  end

  def create
    @benefit = Benefit.new(benefit_arguments)
    @benefit.save
    redirect_to action: 'index'
  end

  def destroy
    @benefit = Benefit.find(params[:id])
    @benefit.destroy
    redirect_to action: 'index'
  end

  def benefit_arguments
    params.require(:benefit).permit(:name, :benefit_type)
  end
end
