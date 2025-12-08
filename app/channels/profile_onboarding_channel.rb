class ProfileOnboardingChannel < ApplicationCable::Channel
  def subscribed
    @profile = current_user.profile
    stream_from "profile_onboarding_#{@profile.id}"
    
    # Send initial welcome message if starting onboarding
    if @profile.needs_onboarding? && @profile.onboarding_step.blank?
      @profile.update(onboarding_step: 'intro')
      send_initial_message
    end
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

    # Save user message
    user_message = data['content']
    
    # Broadcast user message immediately
    ActionCable.server.broadcast(
      "profile_onboarding_#{@profile.id}",
      {
        type: 'user-message',
        content: user_message,
        timestamp: Time.current.iso8601
      }
    )

    # Process with AI service
    service = ProfileOnboardingService.new(@profile, user_message, @profile.onboarding_step)
    result = service.call

    if result[:success]
      # Broadcast AI response
      ActionCable.server.broadcast(
        "profile_onboarding_#{@profile.id}",
        {
          type: 'assistant-message',
          content: result[:response],
          step: result[:step],
          next_step: result[:next_step],
          completed: result[:completed] || false,
          profile_preview: result[:profile_preview],
          timestamp: Time.current.iso8601
        }
      )

      # Reload profile to get latest changes
      @profile.reload
    else
      # Broadcast error
      ActionCable.server.broadcast(
        "profile_onboarding_#{@profile.id}",
        {
          type: 'error',
          message: result[:error] || '处理消息时出现错误，请重试。'
        }
      )
    end
  end

  def upload_avatar(data)
    # Avatar upload will be handled via normal form submission
    # This method can be used to trigger UI updates after upload
    @profile.reload
    
    ActionCable.server.broadcast(
      "profile_onboarding_#{@profile.id}",
      {
        type: 'avatar-uploaded',
        avatar_url: @profile.avatar.attached? ? 
          Rails.application.routes.url_helpers.url_for(@profile.avatar) : nil,
        profile_preview: generate_profile_preview
      }
    )
  end

  def skip_step(data)
    # Allow users to skip optional steps
    current_step = @profile.onboarding_step
    service = ProfileOnboardingService.new(@profile, '', current_step)
    next_step = service.send(:next_step_from_current)
    
    @profile.update(onboarding_step: next_step)
    
    ActionCable.server.broadcast(
      "profile_onboarding_#{@profile.id}",
      {
        type: 'step-skipped',
        next_step: next_step,
        message: get_step_prompt(next_step)
      }
    )
  end

  private

  def current_user
    @current_user ||= connection.current_user
  end

  def send_initial_message
    # Get initial prompt without processing (no user message yet)
    step_config = ProfileOnboardingService::ONBOARDING_STEPS['intro']
    result = {
      success: true,
      response: step_config[:prompt],
      step: 'intro',
      next_step: step_config[:next_step],
      is_initial: true
    }

    ActionCable.server.broadcast(
      "profile_onboarding_#{@profile.id}",
      {
        type: 'assistant-message',
        content: result[:response],
        step: 'intro',
        next_step: result[:next_step],
        is_initial: true,
        timestamp: Time.current.iso8601
      }
    )
  end

  def generate_profile_preview
    {
      full_name: @profile.full_name,
      title: @profile.title,
      company: @profile.company,
      phone: @profile.phone,
      email: @profile.email,
      location: @profile.location,
      bio: @profile.bio,
      specializations: @profile.specializations_array,
      avatar_url: @profile.avatar.attached? ? 
        Rails.application.routes.url_helpers.url_for(@profile.avatar) : nil
    }
  rescue StandardError
    {}
  end

  def get_step_prompt(step)
    ProfileOnboardingService::ONBOARDING_STEPS[step]&.dig(:prompt) || '请继续...'
  end
end
