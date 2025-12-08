class LlmStreamJob < ApplicationJob
  queue_as :llm

  # Retry strategy configuration
  retry_on Net::ReadTimeout, wait: 5.seconds, attempts: 3
  retry_on LlmService::TimeoutError, wait: 5.seconds, attempts: 3
  retry_on LlmService::ApiError, wait: 10.seconds, attempts: 2

  # Streaming LLM responses via ActionCable
  # Usage:
  #   LlmStreamJob.perform_later(chat_id: 123, prompt: "Hello")
  #   LlmStreamJob.perform_later(chat_id: 123, prompt: "...", tools: [...], tool_handler: ...)
  #
  # CRITICAL: ALL broadcasts MUST have 'type' field (auto-routes to client handler)
  # - type: 'chunk' → client calls handleChunk(data)
  # - type: 'done' → client calls handleDone(data)
  # - type: 'tool_call' → (optional) client calls handleToolCall(data)
  #
  # ⚠️  DO NOT rescue exceptions here!
  # ApplicationJob handles all exceptions globally and reports them automatically.
  # If you catch exceptions here, they will be "swallowed" and not reported.
  #
  # Example 1: Basic streaming
  #   def perform(chat_id:, prompt:, system: nil, **options)
  #     full_content = ""
  #
  #     LlmService.call(prompt: prompt, system: system, **options) do |chunk|
  #       full_content += chunk
  #       ActionCable.server.broadcast("chat_#{chat_id}", {
  #         type: 'chunk',
  #         chunk: chunk
  #       })
  #     end
  #
  #     ActionCable.server.broadcast("chat_#{chat_id}", {
  #       type: 'done',
  #       content: full_content
  #     })
  #   end
  #
  # Example 2: With tool calling (tools/tool_handler passed in **options)
  #   def perform(chat_id:, prompt:, system: nil, **options)
  #     # Wrap tool_handler to broadcast tool calls
  #     original_handler = options[:tool_handler]
  #     options[:tool_handler] = ->(name, args) {
  #       ActionCable.server.broadcast("chat_#{chat_id}", {
  #         type: 'tool_call',
  #         tool_name: name,
  #         arguments: args
  #       })
  #       original_handler.call(name, args)
  #     } if original_handler
  #
  #     full_content = ""
  #     LlmService.call(prompt: prompt, system: system, **options) do |chunk|
  #       full_content += chunk
  #       ActionCable.server.broadcast("chat_#{chat_id}", { type: 'chunk', chunk: chunk })
  #     end
  #
  #     ActionCable.server.broadcast("chat_#{chat_id}", { type: 'done', content: full_content })
  #   end
  def perform(chat_session_id:, prompt:)
    chat_session = ChatSession.find(chat_session_id)
    channel_name = "profile_chat_#{chat_session_id}"
    full_content = ""

    # Build context from chat history
    previous_messages = chat_session.chat_messages.recent.limit(10)
    system_prompt = build_system_prompt(chat_session.profile)

    # Stream LLM response
    LlmService.call(prompt: prompt, system: system_prompt) do |chunk|
      full_content += chunk
      ActionCable.server.broadcast(channel_name, {
        type: 'assistant-chunk',
        chunk: chunk
      })
    end

    # Save assistant message
    assistant_message = chat_session.chat_messages.create!(
      role: 'assistant',
      content: full_content
    )

    # Notify completion
    ActionCable.server.broadcast(channel_name, {
      type: 'assistant-done',
      id: assistant_message.id,
      content: full_content,
      created_at: assistant_message.created_at.iso8601
    })
  end

  private

  def build_system_prompt(profile)
    <<~PROMPT
      你是#{profile.full_name}的AI助手。你的职责是回答访客关于专业服务的咨询。

      专业人士信息：
      - 姓名：#{profile.full_name}
      - 职位：#{profile.title}
      - 公司：#{profile.company}
      - 专业领域：#{profile.specializations_array.join('、')}
      - 简介：#{profile.bio}

      请以专业、友好的方式回答问题。如果问题超出你的知识范围，请礼貌地说明并建议直接联系专业人士。
      回答要简洁明了，重点突出，避免冗长。
    PROMPT
  end
end
