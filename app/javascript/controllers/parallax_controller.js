import { Controller } from "@hotwired/stimulus"

// Parallax Controller
// Handles parallax scrolling effects for elements
export default class extends Controller {
  static values = {
    speed: { type: Number, default: 0.5 },
    offset: { type: Number, default: 0 }
  }

  connect() {
    this.rafId = null
    this.handleScroll = this.handleScroll.bind(this)

    // Set initial position
    this.updatePosition()

    // Add scroll listener with passive option for better performance
    window.addEventListener('scroll', this.handleScroll, { passive: true })

    // Check if element is an image and wait for it to load
    if (this.element.tagName === 'IMG' && !this.element.complete) {
      this.element.addEventListener('load', () => this.updatePosition())
    }
  }

  disconnect() {
    window.removeEventListener('scroll', this.handleScroll)
    if (this.rafId) {
      cancelAnimationFrame(this.rafId)
    }
  }

  handleScroll() {
    // Use requestAnimationFrame to throttle updates
    if (!this.rafId) {
      this.rafId = requestAnimationFrame(() => {
        this.updatePosition()
        this.rafId = null
      })
    }
  }

  updatePosition() {
    const rect = this.element.getBoundingClientRect()
    const windowHeight = window.innerHeight

    // Check if element is in viewport
    if (rect.bottom < 0 || rect.top > windowHeight) {
      return
    }

    // Calculate parallax offset
    const scrolled = window.scrollY
    const elementTop = rect.top + scrolled
    const elementMiddle = elementTop + rect.height / 2
    const windowMiddle = scrolled + windowHeight / 2
    const distanceFromMiddle = elementMiddle - windowMiddle

    // Apply parallax transform
    const translateY = distanceFromMiddle * this.speedValue + this.offsetValue

    // Use transform for better performance (GPU acceleration)
    this.element.style.transform = `translateY(${translateY}px)`
    this.element.style.willChange = 'transform'
  }
}