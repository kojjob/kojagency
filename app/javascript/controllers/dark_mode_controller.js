import { Controller } from "@hotwired/stimulus"

// Dark Mode Controller
// Handles theme switching between light and dark modes
export default class extends Controller {
  connect() {
    // Check for saved theme preference or default to light
    this.theme = localStorage.getItem('theme') || 'light'
    this.applyTheme()

    // Check system preference if no saved preference
    if (!localStorage.getItem('theme')) {
      if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        this.theme = 'dark'
        this.applyTheme()
      }
    }

    // Listen for system theme changes
    window.matchMedia('(prefers-color-scheme: dark)')
      .addEventListener('change', this.handleSystemThemeChange.bind(this))
  }

  disconnect() {
    window.matchMedia('(prefers-color-scheme: dark)')
      .removeEventListener('change', this.handleSystemThemeChange)
  }

  toggle(event) {
    event?.preventDefault()

    // Toggle theme
    this.theme = this.theme === 'light' ? 'dark' : 'light'
    this.applyTheme()

    // Save preference
    localStorage.setItem('theme', this.theme)

    // Animate the toggle
    this.animateToggle()
  }

  applyTheme() {
    const html = document.documentElement

    if (this.theme === 'dark') {
      html.classList.add('dark')
      html.style.colorScheme = 'dark'
    } else {
      html.classList.remove('dark')
      html.style.colorScheme = 'light'
    }

    // Update all toggle buttons' icons
    this.updateToggleIcons()
  }

  updateToggleIcons() {
    // Find all dark mode toggle buttons
    const toggleButtons = document.querySelectorAll('[data-action*="dark-mode#toggle"]')

    toggleButtons.forEach(button => {
      const moonIcon = button.querySelector('.fa-moon')
      const sunIcon = button.querySelector('.fa-sun')

      if (moonIcon && sunIcon) {
        if (this.theme === 'dark') {
          moonIcon.classList.add('hidden')
          sunIcon.classList.remove('hidden')
        } else {
          moonIcon.classList.remove('hidden')
          sunIcon.classList.add('hidden')
        }
      }
    })
  }

  animateToggle() {
    // Create ripple effect from the button
    const button = event?.currentTarget
    if (!button) return

    const rect = button.getBoundingClientRect()
    const ripple = document.createElement('div')

    // Calculate the maximum radius needed to cover the entire screen
    const maxRadius = Math.sqrt(
      Math.pow(Math.max(rect.left, window.innerWidth - rect.left), 2) +
      Math.pow(Math.max(rect.top, window.innerHeight - rect.top), 2)
    )

    ripple.style.cssText = `
      position: fixed;
      left: ${rect.left + rect.width / 2}px;
      top: ${rect.top + rect.height / 2}px;
      width: 0;
      height: 0;
      border-radius: 50%;
      background: ${this.theme === 'dark' ? 'rgba(31, 41, 55, 0.5)' : 'rgba(255, 255, 255, 0.5)'};
      pointer-events: none;
      z-index: 9999;
      transform: translate(-50%, -50%);
      transition: width 0.6s ease-out, height 0.6s ease-out, opacity 0.6s ease-out;
    `

    document.body.appendChild(ripple)

    // Trigger the animation
    requestAnimationFrame(() => {
      ripple.style.width = `${maxRadius * 2}px`
      ripple.style.height = `${maxRadius * 2}px`
      ripple.style.opacity = '0'
    })

    // Remove the ripple after animation
    setTimeout(() => ripple.remove(), 600)
  }

  handleSystemThemeChange(event) {
    // Only apply system theme if user hasn't manually set a preference
    if (!localStorage.getItem('theme')) {
      this.theme = event.matches ? 'dark' : 'light'
      this.applyTheme()
    }
  }
}