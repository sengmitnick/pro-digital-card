class Admin::MemberCategoriesController < Admin::BaseController
  before_action :set_categories, only: [:index, :update]

  def index
    # 获取所有类别及其统计信息
    @categories = Profile::MEMBER_CATEGORIES.map do |category|
      {
        name: category,
        count: Profile.where(member_category: category).count
      }
    end
    
    @total_members = Profile.count
    @categorized_members = Profile.where.not(member_category: nil).count
    @uncategorized_members = Profile.where(member_category: nil).count
  end

  def update
    category = params[:category]
    action = params[:action_type]
    
    # 验证类别是否存在
    unless Profile::MEMBER_CATEGORIES.include?(category)
      return render json: { success: false, error: '无效的类别' }, status: :unprocessable_entity
    end
    
    case action
    when 'add'
      new_category = params[:new_category]&.strip
      if new_category.blank?
        return render json: { success: false, error: '类别名称不能为空' }, status: :unprocessable_entity
      end
      
      if Profile::MEMBER_CATEGORIES.include?(new_category)
        return render json: { success: false, error: '类别已存在' }, status: :unprocessable_entity
      end
      
      # 添加新类别到常量（需要修改模型文件）
      render json: { success: false, error: '添加类别功能需要修改代码实现' }, status: :unprocessable_entity
      
    when 'remove'
      # 检查是否有成员使用此类别
      count = Profile.where(member_category: category).count
      if count > 0
        return render json: { 
          success: false, 
          error: "无法删除：还有 #{count} 个成员使用此类别，请先修改这些成员的类别" 
        }, status: :unprocessable_entity
      end
      
      # 删除类别（需要修改模型文件）
      render json: { success: false, error: '删除类别功能需要修改代码实现' }, status: :unprocessable_entity
      
    else
      render json: { success: false, error: '无效的操作' }, status: :unprocessable_entity
    end
  end

  private

  def set_categories
    @categories = Profile::MEMBER_CATEGORIES
  end
end
