class DashboardAssistantChannel < ApplicationCable::Channel
  def subscribed
    @profile = current_user.profile
    stream_from "dashboard_assistant_#{@profile.id}"
    
    # Send welcome message
    send_welcome_message
  rescue StandardError => e
    handle_channel_error(e)
    reject
  end

  def unsubscribed
    # Cleanup if needed
  rescue StandardError => e
    handle_channel_error(e)
  end

  def send_message(data)
    return unless data['content'].present?

    user_message = data['content']
    
    # Broadcast user message immediately
    ActionCable.server.broadcast(
      "dashboard_assistant_#{@profile.id}",
      {
        type: 'user-message',
        content: user_message,
        timestamp: Time.current.iso8601
      }
    )

    # Process with AI assistant service
    service = DashboardAssistantService.new(@profile, user_message)
    result = service.call

    if result[:success]
      # Reload profile if updates were made
      @profile.reload if result[:updated]

      # Broadcast AI response
      ActionCable.server.broadcast(
        "dashboard_assistant_#{@profile.id}",
        {
          type: 'assistant-message',
          content: result[:response],
          updated: result[:updated] || false,
          updated_fields: result[:updated_fields] || [],
          profile_data: generate_profile_data,
          timestamp: Time.current.iso8601
        }
      )
    else
      # Broadcast error
      ActionCable.server.broadcast(
        "dashboard_assistant_#{@profile.id}",
        {
          type: 'error',
          message: result[:error] || '处理消息时出现错误，请重试。'
        }
      )
    end
  end

  def update_profile(data)
    # Direct profile update (for future MCP tools integration)
    updates = data['updates'] || {}
    
    if @profile.update(updates)
      @profile.reload
      
      ActionCable.server.broadcast(
        "dashboard_assistant_#{@profile.id}",
        {
          type: 'profile-updated',
          success: true,
          updated_fields: updates.keys,
          profile_data: generate_profile_data
        }
      )
    else
      ActionCable.server.broadcast(
        "dashboard_assistant_#{@profile.id}",
        {
          type: 'error',
          message: '更新失败，请重试。'
        }
      )
    end
  end

  private

  def current_user
    @current_user ||= connection.current_user
  end

  def send_welcome_message
    ActionCable.server.broadcast(
      "dashboard_assistant_#{@profile.id}",
      {
        type: 'assistant-message',
        content: "你好！我是你的AI助手 👋\n\n你可以直接告诉我想要更新的名片信息，比如：\n• \"帮我把电话改成 138-xxxx-xxxx\"\n• \"更新一下我的个人简介\"\n• \"添加专业领域：合同法\"\n\n我会帮你快速完成更新！",
        is_welcome: true,
        timestamp: Time.current.iso8601
      }
    )
  end

  def generate_profile_data
    {
      full_name: @profile.full_name,
      title: @profile.title,
      company: @profile.company,
      phone: @profile.phone,
      email: @profile.email,
      location: @profile.location,
      bio: @profile.bio,
      specializations: @profile.specializations_array,
      stats: @profile.stats
    }
  end
end
