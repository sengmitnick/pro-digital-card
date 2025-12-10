class Admin::OrganizationsController < Admin::BaseController
  before_action :set_organization

  def edit
  end

  def update
    if @organization.update(organization_params)
      redirect_to edit_admin_organization_path, notice: '组织设置已成功更新。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def members
    @pending_profiles = @organization.pending_profiles.page(params[:pending_page]).per(10)
    @approved_profiles = @organization.approved_profiles.page(params[:approved_page]).per(10)
    @rejected_profiles = @organization.rejected_profiles.page(params[:rejected_page]).per(10)
  end

  def approve_member
    profile = @organization.profiles.find(params[:profile_id])
    if profile.approve!
      redirect_to members_admin_organization_path(@organization), notice: '成员已成功批准。'
    else
      redirect_to members_admin_organization_path(@organization), alert: '批准成员失败。'
    end
  end

  def reject_member
    profile = @organization.profiles.find(params[:profile_id])
    if profile.reject!
      redirect_to members_admin_organization_path(@organization), notice: '成员已成功拒绝。'
    else
      redirect_to members_admin_organization_path(@organization), alert: '拒绝成员失败。'
    end
  end

  def reactivate_member
    profile = @organization.profiles.find(params[:profile_id])
    if profile.update(status: 'pending')
      redirect_to members_admin_organization_path(@organization), notice: '成员已成功移至待审核列表。'
    else
      redirect_to members_admin_organization_path(@organization), alert: '重新审核成员失败。'
    end
  end

  def destroy_member
    profile = @organization.profiles.find(params[:profile_id])
    if profile.destroy
      redirect_to members_admin_organization_path(@organization), notice: '成员已永久删除。'
    else
      redirect_to members_admin_organization_path(@organization), alert: '删除成员失败。'
    end
  end

  private

  def set_organization
    @organization = Organization.first_or_create!(
      name: '默认组织',
      description: '系统默认组织'
    )
  end

  def organization_params
    params.require(:organization).permit(:name, :description, :logo, :background_image)
  end
end
