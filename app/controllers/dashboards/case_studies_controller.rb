class Dashboards::CaseStudiesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_profile
  before_action :set_case_study, only: [:show, :edit, :update, :destroy]

  def index
    @case_studies = @profile.case_studies.order(position: :asc, created_at: :desc).page(params[:page]).per(20)
  end

  def show
  end

  def new
    @case_study = @profile.case_studies.build
  end

  def edit
  end

  def create
    @case_study = @profile.case_studies.build(case_study_params)
    
    if @case_study.save
      redirect_to dashboards_case_studies_path, notice: '案例创建成功'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @case_study.update(case_study_params)
      redirect_to dashboards_case_studies_path, notice: '案例更新成功'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @case_study.destroy
    redirect_to dashboards_case_studies_path, notice: '案例删除成功'
  end

  private
  
  def set_profile
    @profile = current_user.profile || current_user.create_profile(
      full_name: current_user.name || current_user.email.split('@').first.titleize,
      title: 'Professional',
      email: current_user.email
    )
  end
  
  def set_case_study
    @case_study = @profile.case_studies.find(params[:id])
  end
  
  def case_study_params
    params.require(:case_study).permit(:title, :category, :date, :description, :position)
  end
end
