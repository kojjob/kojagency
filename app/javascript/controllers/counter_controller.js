import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display"]
  static values = {
    endValue: Number,
    delay: { type: Number, default: 0 },
    duration: { type: Number, default: 2000 }
  }

  connect() {
    // Use Intersection Observer to trigger animation when visible
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.hasAnimated) {
          this.hasAnimated = true
          setTimeout(() => {
            this.animate()
          }, this.delayValue)
        }
      })
    }, {
      threshold: 0.5
    })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
    if (this.animationFrame) {
      cancelAnimationFrame(this.animationFrame)
    }
  }

  animate() {
    const startTime = Date.now()
    const startValue = 0
    const endValue = this.endValueValue || parseInt(this.displayTarget.textContent) || 100

    const updateCount = () => {
      const currentTime = Date.now()
      const elapsed = currentTime - startTime
      const progress = Math.min(elapsed / this.durationValue, 1)

      // Easing function for smooth animation
      const easeOutQuart = 1 - Math.pow(1 - progress, 4)
      const currentValue = Math.floor(startValue + (endValue - startValue) * easeOutQuart)

      this.displayTarget.textContent = currentValue

      if (progress < 1) {
        this.animationFrame = requestAnimationFrame(updateCount)
      }
    }

    updateCount()
  }
}