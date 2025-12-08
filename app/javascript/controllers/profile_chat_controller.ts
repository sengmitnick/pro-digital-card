import BaseChannelController from "./base_channel_controller"

/**
 * ProfileChat Controller - Handles WebSocket + UI for profile chat
 */
export default class extends BaseChannelController {
  static targets = [
    "messages",
    "input",
    "form",
    "sendButton"
  ]

  static values = {
    profileId: Number,
    visitorName: String,
    visitorEmail: String
  }

  declare messagesTarget: HTMLElement
  declare inputTarget: HTMLInputElement
  declare formTarget: HTMLFormElement
  declare sendButtonTarget: HTMLButtonElement
  declare profileIdValue: number
  declare visitorNameValue: string
  declare visitorEmailValue: string

  private currentAssistantBubble: HTMLElement | null = null
  private currentAssistantContent = ""

  connect(): void {
    console.log("ProfileChat controller connected")

    this.createSubscription("ProfileChatChannel", {
      profile_id: this.profileIdValue,
      visitor_name: this.visitorNameValue,
      visitor_email: this.visitorEmailValue
    })

    // Enable form after connection
    this.formTarget.addEventListener('submit', this.handleSubmit.bind(this))
  }

  disconnect(): void {
    this.destroySubscription()
  }

  protected channelConnected(): void {
    console.log("Chat channel connected")
    this.enableInput()
  }

  protected channelDisconnected(): void {
    console.log("Chat channel disconnected")
    this.disableInput()
  }

  // Handle user message from server (confirmation)
  protected handleUserMessage(data: any): void {
    // User message already added locally, just scroll
    this.scrollToBottom()
  }

  // Handle AI assistant streaming chunks
  protected handleAssistantChunk(data: any): void {
    if (!this.currentAssistantBubble) {
      this.currentAssistantBubble = this.createAssistantBubble()
      this.messagesTarget.appendChild(this.currentAssistantBubble)
    }

    this.currentAssistantContent += data.chunk
    const contentElement = this.currentAssistantBubble.querySelector('.message-content')
    if (contentElement) {
      contentElement.textContent = this.currentAssistantContent
    }

    this.scrollToBottom()
  }

  // Handle AI assistant completion
  protected handleAssistantDone(data: any): void {
    this.currentAssistantBubble = null
    this.currentAssistantContent = ""
    this.enableInput()
    this.scrollToBottom()
  }

  // UI Methods
  private handleSubmit(event: Event): void {
    event.preventDefault()
    
    const content = this.inputTarget.value.trim()
    if (!content) return

    // Add user message to UI immediately
    this.addUserMessage(content)

    // Send to server via WebSocket
    this.perform('send_message', { content: content })

    // Clear input and disable while waiting
    this.inputTarget.value = ''
    this.disableInput()
    this.scrollToBottom()
  }

  private addUserMessage(content: string): void {
    const messageEl = document.createElement('div')
    messageEl.className = 'chat-message chat-message-user'
    messageEl.innerHTML = `
      <div class="chat-bubble chat-bubble-user">
        <p class="text-sm">${this.escapeHtml(content)}</p>
      </div>
    `
    this.messagesTarget.appendChild(messageEl)
  }

  private createAssistantBubble(): HTMLElement {
    const messageEl = document.createElement('div')
    messageEl.className = 'chat-message'
    messageEl.innerHTML = `
      <div class="avatar avatar-sm flex-shrink-0">
        <div class="w-full h-full bg-primary/10 flex items-center justify-center">
          <svg class="w-5 h-5 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
          </svg>
        </div>
      </div>
      <div class="chat-bubble chat-bubble-assistant">
        <p class="text-sm message-content"></p>
      </div>
    `
    return messageEl
  }

  private enableInput(): void {
    this.inputTarget.disabled = false
    this.sendButtonTarget.disabled = false
  }

  private disableInput(): void {
    this.inputTarget.disabled = true
    this.sendButtonTarget.disabled = true
  }

  private scrollToBottom(): void {
    this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
  }

  private escapeHtml(text: string): string {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
