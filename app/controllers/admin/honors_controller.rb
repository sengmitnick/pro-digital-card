class Admin::HonorsController < Admin::BaseController
  before_action :set_honor, only: [:show, :edit, :update, :destroy]

  def index
    @honors = Honor.page(params[:page]).per(10)
  end

  def show
  end

  def new
    @honor = Honor.new
  end

  def create
    @honor = Honor.new(honor_params)

    if @honor.save
      redirect_to admin_honor_path(@honor), notice: 'Honor was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @honor.update(honor_params)
      redirect_to admin_honor_path(@honor), notice: 'Honor was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @honor.destroy
    redirect_to admin_honors_path, notice: 'Honor was successfully deleted.'
  end

  private

  def set_honor
    @honor = Honor.find(params[:id])
  end

  def honor_params
    params.require(:honor).permit(:title, :organization, :date, :description, :icon_name, :profile_id)
  end
end
