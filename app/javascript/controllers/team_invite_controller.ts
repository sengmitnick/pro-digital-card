import { Controller } from "@hotwired/stimulus"

export default class extends Controller<HTMLElement> {
  static values = {
    orgName: String,
    inviteToken: String
  }

  declare readonly orgNameValue: string
  declare readonly inviteTokenValue: string

  connect(): void {
    console.log("TeamInvite connected")
  }

  disconnect(): void {
    console.log("TeamInvite disconnected")
  }

  generateInvite(): void {
    // Generate invite URL (assuming the invitation page accepts token param)
    const inviteUrl = `${window.location.origin}/invitation/new?token=${this.inviteTokenValue}`
    
    // Generate invite message
    const inviteMessage = `您好！

诚邀您加入「${this.orgNameValue}」团队。

请点击以下链接完成注册并加入团队：
${inviteUrl}

期待您的加入！`
    
    // Copy to clipboard
    this.copyToClipboard(inviteMessage)
  }

  private copyToClipboard(text: string): void {
    // Use global copyToClipboard function from clipboard_utils.ts
    if (typeof window.copyToClipboard === 'function') {
      window.copyToClipboard(text)
        .then(() => {
          this.showSuccess('邀请链接和文案已复制到剪贴板！')
        })
        .catch((error: Error) => {
          this.showError('复制失败，请重试')
          console.error('Copy failed:', error)
        })
    } else {
      this.showError('复制功能不可用')
    }
  }

  private showSuccess(message: string): void {
    // Create a temporary toast notification
    const toast = document.createElement('div')
    toast.className = 'fixed top-4 right-4 z-50 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg transition-opacity duration-300'
    toast.textContent = message
    document.body.appendChild(toast)

    // Auto remove after 3 seconds
    setTimeout(() => {
      toast.style.opacity = '0'
      setTimeout(() => {
        document.body.removeChild(toast)
      }, 300)
    }, 3000)
  }

  private showError(message: string): void {
    // Create a temporary error toast notification
    const toast = document.createElement('div')
    toast.className = 'fixed top-4 right-4 z-50 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg transition-opacity duration-300'
    toast.textContent = message
    document.body.appendChild(toast)

    // Auto remove after 3 seconds
    setTimeout(() => {
      toast.style.opacity = '0'
      setTimeout(() => {
        document.body.removeChild(toast)
      }, 300)
    }, 3000)
  }
}
