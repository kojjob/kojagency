import { Controller } from "@hotwired/stimulus"

// Newsletter Signup Controller
// Handles newsletter subscription form interactions
export default class extends Controller {
  static targets = ["form", "email", "submitButton"]

  connect() {
    console.log("Newsletter signup controller connected")
  }

  subscribe(event) {
    // The form will submit via Rails form_with helper
    // This method can be used for additional client-side validation or feedback
    const email = this.emailTarget?.value

    if (email && this.isValidEmail(email)) {
      // Optional: Show loading state
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.textContent = "Subscribing..."
        this.submitButtonTarget.disabled = true
      }
    } else {
      event.preventDefault()
      this.showError("Please enter a valid email address")
    }
  }

  // Handle successful subscription (called via Turbo response)
  subscriptionSuccess() {
    this.showSuccess("Thank you for subscribing!")
    if (this.hasEmailTarget) {
      this.emailTarget.value = ""
    }
    this.resetButton()
  }

  // Handle subscription error (called via Turbo response)
  subscriptionError(message = "An error occurred. Please try again.") {
    this.showError(message)
    this.resetButton()
  }

  // Private methods
  isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  }

  showSuccess(message) {
    this.showToast(message, "success")
  }

  showError(message) {
    this.showToast(message, "error")
  }

  showToast(message, type = "info") {
    // Create toast notification
    const toast = document.createElement('div')
    toast.className = `fixed bottom-24 left-1/2 transform -translate-x-1/2 px-6 py-3 rounded-full text-sm font-medium shadow-lg z-50 transition-all duration-300 opacity-0 translate-y-4 ${
      type === 'success' ? 'bg-green-600 text-white' :
      type === 'error' ? 'bg-red-600 text-white' :
      'bg-gray-900 text-white'
    }`
    toast.textContent = message

    document.body.appendChild(toast)

    // Animate in
    setTimeout(() => {
      toast.classList.remove('opacity-0', 'translate-y-4')
      toast.classList.add('opacity-100', 'translate-y-0')
    }, 10)

    // Remove after 3 seconds
    setTimeout(() => {
      toast.classList.add('opacity-0', 'translate-y-4')
      toast.classList.remove('opacity-100', 'translate-y-0')
      setTimeout(() => toast.remove(), 300)
    }, 3000)
  }

  resetButton() {
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.textContent = "Subscribe"
      this.submitButtonTarget.disabled = false
    }
  }
}