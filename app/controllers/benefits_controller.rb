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
      flash[:notice] = 'Benefit Updated Successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = @benefit.errors.full_messages
      redirect_back(fallback_location: root_path)
    end
  end

  def create
    @benefit = Benefit.new(benefit_arguments)
    if @benefit.save
      flash[:notice] = 'Benefit Created Successfully'
      redirect_to action: 'index'
    else
      flash[:alert] = @benefit.errors.full_messages
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    @benefit = Benefit.find(params[:id])
    if @benefit.destroy
      flash[:notice] = 'Benefit Deleted Successfully'
    else
      flash[:alert] = @benefit.errors.full_messages
    end
    redirect_to action: 'index'
  end

  def benefit_arguments
    params.require(:benefit).permit(:name, :benefit_type)
  end
end
