class CardsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    @profile = Profile.friendly.find(params[:id])
    @case_studies = @profile.case_studies.limit(10)
    @honors = @profile.honors.limit(8)
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: '找不到该专业名片'
  end

  private
  # Write your private methods here
end
