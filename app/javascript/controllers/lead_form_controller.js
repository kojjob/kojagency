import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lead-form"
export default class extends Controller {
  static targets = [
    "firstName", "lastName", "email", "phone", "company", "website",
    "projectType", "budget", "timeline", "projectDescription",
    "submitButton", "charCount"
  ]

  connect() {
    console.log("Lead form controller connected")
    this.setupValidation()
  }

  setupValidation() {
    // Add real-time validation listeners
    if (this.hasFirstNameTarget) {
      this.firstNameTarget.addEventListener('blur', () => this.validateFirstName())
      this.firstNameTarget.addEventListener('input', () => this.clearFieldError(this.firstNameTarget))
    }

    if (this.hasLastNameTarget) {
      this.lastNameTarget.addEventListener('blur', () => this.validateLastName())
      this.lastNameTarget.addEventListener('input', () => this.clearFieldError(this.lastNameTarget))
    }

    if (this.hasEmailTarget) {
      this.emailTarget.addEventListener('blur', () => this.validateEmail())
      this.emailTarget.addEventListener('input', () => this.clearFieldError(this.emailTarget))
    }

    if (this.hasPhoneTarget) {
      this.phoneTarget.addEventListener('blur', () => this.validatePhone())
      this.phoneTarget.addEventListener('input', () => this.clearFieldError(this.phoneTarget))
    }

    if (this.hasProjectDescriptionTarget) {
      this.projectDescriptionTarget.addEventListener('input', () => {
        this.updateCharCount()
        this.validateProjectDescription()
      })
      this.projectDescriptionTarget.addEventListener('blur', () => this.validateProjectDescription())
    }
  }

  validateForm(event) {
    let isValid = true

    // Validate all required fields
    if (!this.validateFirstName()) isValid = false
    if (!this.validateLastName()) isValid = false
    if (!this.validateEmail()) isValid = false
    if (!this.validatePhone()) isValid = false
    if (!this.validateProjectType()) isValid = false
    if (!this.validateBudget()) isValid = false
    if (!this.validateTimeline()) isValid = false
    if (!this.validateProjectDescription()) isValid = false

    if (!isValid) {
      event.preventDefault()
      this.scrollToFirstError()
    }

    return isValid
  }

  validateFirstName() {
    const value = this.firstNameTarget.value.trim()

    if (value.length === 0) {
      this.showError(this.firstNameTarget, "First name is required")
      return false
    }

    if (value.length > 50) {
      this.showError(this.firstNameTarget, "First name must be 50 characters or less")
      return false
    }

    this.clearError(this.firstNameTarget)
    return true
  }

  validateLastName() {
    const value = this.lastNameTarget.value.trim()

    if (value.length === 0) {
      this.showError(this.lastNameTarget, "Last name is required")
      return false
    }

    if (value.length > 50) {
      this.showError(this.lastNameTarget, "Last name must be 50 characters or less")
      return false
    }

    this.clearError(this.lastNameTarget)
    return true
  }

  validateEmail() {
    const value = this.emailTarget.value.trim()
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

    if (value.length === 0) {
      this.showError(this.emailTarget, "Email is required")
      return false
    }

    if (!emailRegex.test(value)) {
      this.showError(this.emailTarget, "Please enter a valid email address")
      return false
    }

    this.clearError(this.emailTarget)
    return true
  }

  validatePhone() {
    if (!this.hasPhoneTarget) return true

    const value = this.phoneTarget.value.trim()

    // Phone is optional, but if provided must be valid
    if (value.length > 0) {
      const phoneRegex = /^[\+]?[1-9][\d\s\-\(\)]*$/

      if (!phoneRegex.test(value)) {
        this.showError(this.phoneTarget, "Please enter a valid phone number")
        return false
      }
    }

    this.clearError(this.phoneTarget)
    return true
  }

  validateProjectType() {
    const value = this.projectTypeTarget.value

    if (value === "" || value === null) {
      this.showError(this.projectTypeTarget, "Please select a project type")
      return false
    }

    this.clearError(this.projectTypeTarget)
    return true
  }

  validateBudget() {
    const value = this.budgetTarget.value

    if (value === "" || value === null) {
      this.showError(this.budgetTarget, "Please select a budget range")
      return false
    }

    this.clearError(this.budgetTarget)
    return true
  }

  validateTimeline() {
    const value = this.timelineTarget.value

    if (value === "" || value === null) {
      this.showError(this.timelineTarget, "Please select a timeline")
      return false
    }

    this.clearError(this.timelineTarget)
    return true
  }

  validateProjectDescription() {
    const value = this.projectDescriptionTarget.value.trim()

    if (value.length === 0) {
      this.showError(this.projectDescriptionTarget, "Project description is required")
      return false
    }

    if (value.length < 20) {
      this.showError(this.projectDescriptionTarget, `Project description must be at least 20 characters (currently ${value.length})`)
      return false
    }

    if (value.length > 2000) {
      this.showError(this.projectDescriptionTarget, `Project description must be 2000 characters or less (currently ${value.length})`)
      return false
    }

    this.clearError(this.projectDescriptionTarget)
    return true
  }

  updateCharCount() {
    if (this.hasCharCountTarget) {
      const length = this.projectDescriptionTarget.value.length
      this.charCountTarget.textContent = `${length} / 2000 characters`

      if (length < 20) {
        this.charCountTarget.classList.add('text-red-500')
        this.charCountTarget.classList.remove('text-gray-500', 'text-green-600')
      } else if (length > 1900) {
        this.charCountTarget.classList.add('text-yellow-600')
        this.charCountTarget.classList.remove('text-gray-500', 'text-green-600')
      } else {
        this.charCountTarget.classList.add('text-green-600')
        this.charCountTarget.classList.remove('text-gray-500', 'text-red-500', 'text-yellow-600')
      }
    }
  }

  showError(field, message) {
    // Add error styling to field
    field.classList.add('border-red-500', 'focus:ring-red-500', 'focus:border-red-500')
    field.classList.remove('border-gray-300', 'focus:ring-indigo-500', 'focus:border-indigo-500')

    // Find or create error message element
    let errorElement = field.parentElement.querySelector('.field-error')

    if (!errorElement) {
      errorElement = document.createElement('p')
      errorElement.className = 'field-error mt-1 text-sm text-red-600'
      field.parentElement.appendChild(errorElement)
    }

    errorElement.textContent = message
  }

  clearError(field) {
    // Remove error styling from field
    field.classList.remove('border-red-500', 'focus:ring-red-500', 'focus:border-red-500')
    field.classList.add('border-gray-300', 'focus:ring-indigo-500', 'focus:border-indigo-500')

    // Remove error message if it exists
    const errorElement = field.parentElement.querySelector('.field-error')
    if (errorElement) {
      errorElement.remove()
    }
  }

  clearFieldError(field) {
    // Only clear error if field has content or is not required
    if (field.value.trim().length > 0 || !field.required) {
      this.clearError(field)
    }
  }

  scrollToFirstError() {
    const firstError = this.element.querySelector('.border-red-500')
    if (firstError) {
      firstError.scrollIntoView({ behavior: 'smooth', block: 'center' })
      firstError.focus()
    }
  }

  // Disable submit button while submitting
  submit(event) {
    if (this.validateForm(event)) {
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = true
        this.submitButtonTarget.textContent = "Submitting..."
        this.submitButtonTarget.classList.add('opacity-75', 'cursor-not-allowed')
      }
    }
  }
}