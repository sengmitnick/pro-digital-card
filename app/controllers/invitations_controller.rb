class InvitationsController < ApplicationController
  skip_before_action :set_current_request_details
  before_action :load_organization_from_token

  def new
    unless @organization
      redirect_to root_path, alert: "邀请链接无效或已过期"
      return
    end
    
    @user = User.new
    @user.build_profile
  end

  def create
    unless @organization
      redirect_to root_path, alert: "邀请链接无效或已过期"
      return
    end
    
    @user = User.new(user_params)
    @user.verified = false
    @user.activated = false
    
    if @user.save
      @user.profile.update(
        organization_id: @organization.id,
        status: 'pending',
        email: @user.email
      )
      
      redirect_to root_path, notice: "注册成功！您的申请已提交，请等待管理员审核。审核通过后您将可以登录使用。"
    else
      flash.now[:alert] = "注册失败，请检查表单信息"
      render :new, status: :unprocessable_entity
    end
  end

  private
  
  def load_organization_from_token
    token = params[:token]
    @organization = Organization.find_by(invite_token: token) if token.present?
  end

  def user_params
    params.require(:user).permit(
      :email, :password, :password_confirmation,
      profile_attributes: [:full_name, :title, :department, :bio, :avatar]
    )
  end
end
