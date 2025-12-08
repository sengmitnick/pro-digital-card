import BaseChannelController from "./base_channel_controller"

/**
 * DashboardAssistant Controller - Floating AI assistant widget for dashboard
 */
export default class extends BaseChannelController {
  static targets = [
    "widget",
    "bubble",
    "messages",
    "input",
    "form",
    "sendButton"
  ]

  static values = {
    profileId: Number
  }

  declare widgetTarget: HTMLElement
  declare bubbleTarget: HTMLElement
  declare messagesTarget: HTMLElement
  declare inputTarget: HTMLInputElement
  declare formTarget: HTMLFormElement
  declare sendButtonTarget: HTMLButtonElement
  declare profileIdValue: number

  private isOpen: boolean = false
  private unreadCount: number = 0

  connect(): void {
    console.log("DashboardAssistant controller connected")

    this.createSubscription("DashboardAssistantChannel", {})

    // Setup form submission
    this.formTarget.addEventListener('submit', this.handleSubmit.bind(this))

    // Load widget state from localStorage
    const savedState = localStorage.getItem('dashboard_assistant_open')
    if (savedState === 'true') {
      this.openWidget()
    }
  }

  disconnect(): void {
    this.destroySubscription()
  }

  protected channelConnected(): void {
    console.log("Dashboard assistant channel connected")
    this.enableInput()
  }

  protected channelDisconnected(): void {
    console.log("Dashboard assistant channel disconnected")
    this.disableInput()
  }

  // Handle user message confirmation from server
  protected handleUserMessage(data: any): void {
    this.scrollToBottom()
  }

  // Handle AI assistant messages
  protected handleAssistantMessage(data: any): void {
    this.addAssistantMessage(data.content)

    // If widget is closed, increment unread count
    if (!this.isOpen && !data.is_welcome) {
      this.unreadCount++
      this.updateUnreadBadge()
      
      // Show notification
      this.showNotification('AI助手回复了你')
    }

    // If profile was updated, refresh the page data
    if (data.updated) {
      this.showUpdateNotification(data.updated_fields)
    }

    this.enableInput()
    this.scrollToBottom()
  }

  // Handle errors
  protected handleError(data: any): void {
    this.addErrorMessage(data.message)
    this.enableInput()
    this.scrollToBottom()
  }

  // Handle profile updates
  protected handleProfileUpdated(data: any): void {
    if (data.success) {
      this.showUpdateNotification(data.updated_fields)
      this.addAssistantMessage('名片信息已更新成功！✨')
    }
    this.scrollToBottom()
  }

  // UI Methods
  toggleWidget(): void {
    if (this.isOpen) {
      this.closeWidget()
    } else {
      this.openWidget()
    }
  }

  openWidget(): void {
    this.isOpen = true
    this.widgetTarget.classList.remove('translate-y-full', 'opacity-0')
    this.widgetTarget.classList.add('translate-y-0', 'opacity-100')
    this.bubbleTarget.classList.add('hidden')
    
    // Clear unread count
    this.unreadCount = 0
    this.updateUnreadBadge()
    
    // Save state
    localStorage.setItem('dashboard_assistant_open', 'true')
    
    // Focus input
    setTimeout(() => {
      this.inputTarget.focus()
    }, 300)
  }

  closeWidget(): void {
    this.isOpen = false
    this.widgetTarget.classList.add('translate-y-full', 'opacity-0')
    this.widgetTarget.classList.remove('translate-y-0', 'opacity-100')
    this.bubbleTarget.classList.remove('hidden')
    
    // Save state
    localStorage.setItem('dashboard_assistant_open', 'false')
  }

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
    messageEl.className = 'flex justify-end mb-3'
    messageEl.innerHTML = `
      <div class="max-w-[80%] px-3 py-2 rounded-lg bg-primary text-white text-sm">
        ${this.escapeHtml(content)}
      </div>
    `
    this.messagesTarget.appendChild(messageEl)
  }

  private addAssistantMessage(content: string): void {
    const messageEl = document.createElement('div')
    messageEl.className = 'flex gap-2 mb-3'
    messageEl.innerHTML = `
      <div class="avatar avatar-sm flex-shrink-0 w-7 h-7">
        <div class="w-full h-full bg-primary/10 flex items-center justify-center rounded-full">
          <svg class="w-4 h-4 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
          </svg>
        </div>
      </div>
      <div class="max-w-[80%] px-3 py-2 rounded-lg bg-surface-elevated border border-border text-sm">
        <div class="text-primary whitespace-pre-wrap">${this.escapeHtml(content)}</div>
      </div>
    `
    this.messagesTarget.appendChild(messageEl)
  }

  private addErrorMessage(message: string): void {
    const messageEl = document.createElement('div')
    messageEl.className = 'flex justify-center mb-3'
    messageEl.innerHTML = `
      <div class="alert-danger text-xs max-w-xs px-3 py-2">
        ${this.escapeHtml(message)}
      </div>
    `
    this.messagesTarget.appendChild(messageEl)
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
    setTimeout(() => {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }, 100)
  }

  private updateUnreadBadge(): void {
    const badge = this.bubbleTarget.querySelector('.unread-badge')
    if (badge) {
      if (this.unreadCount > 0) {
        badge.textContent = this.unreadCount > 9 ? '9+' : this.unreadCount.toString()
        badge.classList.remove('hidden')
      } else {
        badge.classList.add('hidden')
      }
    }
  }

  private showNotification(message: string): void {
    // Simple browser notification (can be enhanced)
    if ('Notification' in window && Notification.permission === 'granted') {
      new Notification('AI 助手', {
        body: message,
        icon: '/icon.png'
      })
    }
  }

  private showUpdateNotification(fields: string[]): void {
    // Show a toast notification for profile updates
    const toast = document.createElement('div')
    toast.className = 'fixed top-4 right-4 alert-success shadow-lg z-50 animate-fade-in'
    toast.innerHTML = `
      <div class="flex items-center gap-2">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
        </svg>
        <span>名片信息已更新！</span>
      </div>
    `
    document.body.appendChild(toast)
    
    // Auto-remove after 3 seconds
    setTimeout(() => {
      toast.classList.add('animate-fade-out')
      setTimeout(() => toast.remove(), 300)
    }, 3000)
    
    // Optionally reload page sections to show updates
    setTimeout(() => {
      window.location.reload()
    }, 1500)
  }

  private escapeHtml(text: string): string {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }
}
