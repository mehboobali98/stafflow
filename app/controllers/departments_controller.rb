class DepartmentsController < ApplicationController
  def index
  end
   def show
    @department = Department.all
  end
  def create
  @department=Department.new(department_params)
    if @department.save
      redirect_to :action => 'index'
    else
      flash[:notice]="department not saved"
    end
  end
   def edit
    @department = Department.find(params[:id])
  end
  def update
    @department = Department.find(params[:id])

    if @department.update(department_params)
      redirect_to @department
    end
  end
  def destroy
    @department = Department.find(params[:id])
    @department.destroy
    redirect_to:action=> 'show'
end

  private
def department_params
  params.permit(:name, :image_url)
end

end
