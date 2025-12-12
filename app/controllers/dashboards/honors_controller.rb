class Dashboards::HonorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile
  before_action :set_honor, only: [:show, :edit, :update, :destroy]

  def index
    @honors = @profile.honors.order(date: :desc, created_at: :desc).page(params[:page]).per(20)
  end

  def show
  end

  def new
    @honor = @profile.honors.build
  end

  def edit
  end

  def create
    @honor = @profile.honors.build(honor_params)
    
    if @honor.save
      redirect_to dashboards_honors_path, notice: '荣誉创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @honor.update(honor_params)
      redirect_to dashboards_honors_path, notice: '荣誉更新成功'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @honor.destroy
    redirect_to dashboards_honors_path, notice: '荣誉删除成功'
  end

  private
  
  def set_profile
    @profile = current_user.profile || current_user.create_profile(
      full_name: current_user.name || current_user.email.split('@').first.titleize,
      title: 'Professional',
      email: current_user.email
    )
  end
  
  def set_honor
    @honor = @profile.honors.find(params[:id])
  end
  
  def honor_params
    params.require(:honor).permit(:title, :organization, :date, :description)
  end
end
