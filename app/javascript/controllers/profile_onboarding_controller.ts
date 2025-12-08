import BaseChannelController from "./base_channel_controller"

/**
 * ProfileOnboarding Controller - Handles WebSocket + UI for conversational profile onboarding
 */
export default class extends BaseChannelController {
  static targets = [
    "messages",
    "input",
    "form",
    "sendButton",
    "preview",
    "previewName",
    "previewTitle",
    "previewPhone",
    "previewEmail",
    "previewLocation",
    "previewBio",
    "previewSpecializations",
    "previewAvatar",
    "uploadSection",
    "avatarInput",
    "completionMessage"
  ]

  static values = {
    profileId: Number
  }

  declare messagesTarget: HTMLElement
  declare inputTarget: HTMLInputElement
  declare formTarget: HTMLFormElement
  declare sendButtonTarget: HTMLButtonElement
  declare previewTarget: HTMLElement
  declare previewNameTarget: HTMLElement
  declare previewTitleTarget: HTMLElement
  declare previewPhoneTarget: HTMLElement
  declare previewEmailTarget: HTMLElement
  declare previewLocationTarget: HTMLElement
  declare previewBioTarget: HTMLElement
  declare previewSpecializationsTarget: HTMLElement
  declare previewAvatarTarget: HTMLImageElement
  declare uploadSectionTarget: HTMLElement
  declare avatarInputTarget: HTMLInputElement
  declare completionMessageTarget: HTMLElement
  declare profileIdValue: number

  // Stimulus auto-generated has*Target methods
  declare readonly hasAvatarInputTarget: boolean
  declare readonly hasUploadSectionTarget: boolean
  declare readonly hasPreviewTarget: boolean
  declare readonly hasPreviewNameTarget: boolean
  declare readonly hasPreviewTitleTarget: boolean
  declare readonly hasPreviewPhoneTarget: boolean
  declare readonly hasPreviewEmailTarget: boolean
  declare readonly hasPreviewLocationTarget: boolean
  declare readonly hasPreviewBioTarget: boolean
  declare readonly hasPreviewSpecializationsTarget: boolean
  declare readonly hasPreviewAvatarTarget: boolean
  declare readonly hasCompletionMessageTarget: boolean

  private currentStep: string = 'intro'
  private isCompleted: boolean = false

  connect(): void {
    console.log("ProfileOnboarding controller connected")

    this.createSubscription("ProfileOnboardingChannel", {})
    
    // Setup avatar upload
    if (this.hasAvatarInputTarget) {
      this.avatarInputTarget.addEventListener('change', this.handleAvatarUpload.bind(this))
    }
  }

  disconnect(): void {
    this.destroySubscription()
  }

  protected channelConnected(): void {
    console.log("Onboarding channel connected")
    this.enableInput()
  }

  protected channelDisconnected(): void {
    console.log("Onboarding channel disconnected")
    this.disableInput()
  }

  // Handle user message confirmation from server
  protected handleUserMessage(data: any): void {
    this.scrollToBottom()
  }

  // Handle AI assistant messages
  protected handleAssistantMessage(data: any): void {
    this.addAssistantMessage(data.content)
    this.currentStep = data.next_step || this.currentStep

    // Update preview if profile data changed
    if (data.profile_preview) {
      this.updatePreview(data.profile_preview)
    }

    // Check if onboarding is completed
    if (data.completed) {
      this.handleOnboardingCompleted(data)
    } else {
      this.enableInput()
    }

    this.scrollToBottom()
  }

  // Handle errors
  protected handleError(data: any): void {
    this.addErrorMessage(data.message)
    this.enableInput()
    this.scrollToBottom()
  }

  // Handle avatar upload confirmation
  protected handleAvatarUploaded(data: any): void {
    if (data.avatar_url) {
      this.previewAvatarTarget.src = data.avatar_url
      this.previewAvatarTarget.classList.remove('hidden')
    }
    
    if (data.profile_preview) {
      this.updatePreview(data.profile_preview)
    }
    
    this.addAssistantMessage('太棒了！头像已经上传成功 ✨')
    this.enableInput()
  }

  // Handle step skipped
  protected handleStepSkipped(data: any): void {
    this.currentStep = data.next_step
    this.addAssistantMessage(data.message)
    this.enableInput()
  }

  // UI Methods
  private handleSubmit(event: Event): void {
    event.preventDefault()
    
    const content = this.inputTarget.value.trim()
    if (!content) return

    // Check if avatar step and show upload UI
    if (this.currentStep === 'avatar_upload') {
      if (this.hasUploadSectionTarget) {
        this.uploadSectionTarget.classList.remove('hidden')
      }
    }

    // Add user message to UI immediately
    this.addUserMessage(content)

    // Send to server via WebSocket
    this.perform('send_message', { content: content })

    // Clear input and disable while waiting
    this.inputTarget.value = ''
    this.disableInput()
    this.scrollToBottom()
  }

  private handleAvatarUpload(event: Event): void {
    const input = event.target as HTMLInputElement
    const file = input.files?.[0]
    
    if (!file) return

    // Create FormData and upload via fetch (avatar upload needs file upload)
    const formData = new FormData()
    formData.append('profile[avatar]', file)

    // Show uploading message
    this.addAssistantMessage('正在上传头像...')
    this.disableInput()

    fetch(`/dashboards/settings`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': this.getCsrfToken()
      },
      body: formData
    })
      .then(response => {
        if (response.ok) {
          // Notify channel about successful upload
          this.perform('upload_avatar', {})
        } else {
          throw new Error('Upload failed')
        }
      })
      .catch(error => {
        console.error('Avatar upload error:', error)
        this.addErrorMessage('头像上传失败，请重试')
        this.enableInput()
      })
  }

  private addUserMessage(content: string): void {
    const messageEl = document.createElement('div')
    messageEl.className = 'flex justify-end mb-4'
    messageEl.innerHTML = `
      <div class="max-w-[75%] px-4 py-3 rounded-lg bg-primary text-white">
        <p class="text-sm">${this.escapeHtml(content)}</p>
      </div>
    `
    this.messagesTarget.appendChild(messageEl)
  }

  private addAssistantMessage(content: string): void {
    const messageEl = document.createElement('div')
    messageEl.className = 'flex gap-3 mb-4'
    messageEl.innerHTML = `
      <div class="avatar avatar-sm flex-shrink-0">
        <div class="w-full h-full bg-primary/10 flex items-center justify-center">
          <svg class="w-5 h-5 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-5l-5 5v-5z"/>
          </svg>
        </div>
      </div>
      <div class="max-w-[75%] px-4 py-3 rounded-lg bg-surface-elevated border border-border">
        <p class="text-sm text-primary whitespace-pre-wrap">${this.escapeHtml(content)}</p>
      </div>
    `
    this.messagesTarget.appendChild(messageEl)
  }

  private addErrorMessage(message: string): void {
    const messageEl = document.createElement('div')
    messageEl.className = 'flex justify-center mb-4'
    messageEl.innerHTML = `
      <div class="alert-danger max-w-md">
        <p class="text-sm">${this.escapeHtml(message)}</p>
      </div>
    `
    this.messagesTarget.appendChild(messageEl)
  }

  private updatePreview(data: any): void {
    if (!this.hasPreviewTarget) return

    // Update name
    if (data.full_name && this.hasPreviewNameTarget) {
      this.previewNameTarget.textContent = data.full_name
    }

    // Update title
    if (data.title && this.hasPreviewTitleTarget) {
      const companyText = data.company ? ` · ${data.company}` : ''
      this.previewTitleTarget.textContent = data.title + companyText
    }

    // Update contact info
    if (data.phone && this.hasPreviewPhoneTarget) {
      this.previewPhoneTarget.textContent = data.phone
      const phoneItem = this.previewPhoneTarget.closest('.contact-item')
      phoneItem?.classList.remove('hidden')
    }

    if (data.email && this.hasPreviewEmailTarget) {
      this.previewEmailTarget.textContent = data.email
      const emailItem = this.previewEmailTarget.closest('.contact-item')
      emailItem?.classList.remove('hidden')
    }

    if (data.location && this.hasPreviewLocationTarget) {
      this.previewLocationTarget.textContent = data.location
      const locationItem = this.previewLocationTarget.closest('.contact-item')
      locationItem?.classList.remove('hidden')
    }

    // Update bio
    if (data.bio && this.hasPreviewBioTarget) {
      this.previewBioTarget.textContent = data.bio
      const bioSection = this.previewBioTarget.closest('.bio-section')
      bioSection?.classList.remove('hidden')
    }

    // Update specializations
    const hasSpecs = data.specializations && data.specializations.length > 0
    if (hasSpecs && this.hasPreviewSpecializationsTarget) {
      const badges = data.specializations
        .map((spec: string) => {
          const escapedSpec = this.escapeHtml(spec)
          return `<span class="badge-primary">${escapedSpec}</span>`
        })
        .join('')
      this.previewSpecializationsTarget.innerHTML = badges
      const specsSection = this.previewSpecializationsTarget
        .closest('.specializations-section')
      specsSection?.classList.remove('hidden')
    }

    // Update avatar
    if (data.avatar_url && this.hasPreviewAvatarTarget) {
      this.previewAvatarTarget.src = data.avatar_url
      this.previewAvatarTarget.classList.remove('hidden')
    }

    // Show preview card
    this.previewTarget.classList.remove('opacity-50')
  }

  private handleOnboardingCompleted(data: any): void {
    this.isCompleted = true
    this.disableInput()

    // Show completion message
    if (this.hasCompletionMessageTarget) {
      this.completionMessageTarget.classList.remove('hidden')
    }

    // Hide chat input
    this.formTarget.classList.add('hidden')

    // Add celebration animation to preview
    this.previewTarget.classList.add('animate-pulse')
    setTimeout(() => {
      this.previewTarget.classList.remove('animate-pulse')
    }, 2000)
  }

  private enableInput(): void {
    this.inputTarget.disabled = false
    this.sendButtonTarget.disabled = false
    this.inputTarget.focus()
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

  private escapeHtml(text: string): string {
    const div = document.createElement('div')
    div.textContent = text
    return div.innerHTML
  }

  private getCsrfToken(): string {
    const meta = document.querySelector('meta[name="csrf-token"]')
    return meta ? meta.getAttribute('content') || '' : ''
  }

  // Public action methods
  skipStep(): void {
    this.perform('skip_step', {})
    this.addUserMessage('跳过此步骤')
    this.disableInput()
  }

  viewCard(): void {
    window.open(`/c/${this.profileIdValue}`, '_blank')
  }

  goToDashboard(): void {
    window.location.href = '/dashboards'
  }
}
