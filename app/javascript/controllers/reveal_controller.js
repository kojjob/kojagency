import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 0 },
    threshold: { type: Number, default: 0.3 }
  }

  connect() {
    // Hide element initially
    this.element.style.opacity = "0"
    this.element.style.transform = "translateY(30px)"

    // Create intersection observer
    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.hasRevealed) {
          this.hasRevealed = true
          setTimeout(() => {
            this.reveal()
          }, this.delayValue)
        }
      })
    }, {
      threshold: this.thresholdValue,
      rootMargin: "50px"
    })

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  reveal() {
    this.element.style.transition = "opacity 0.8s ease-out, transform 0.8s ease-out"
    this.element.style.opacity = "1"
    this.element.style.transform = "translateY(0)"

    // Add a subtle scale effect for certain elements
    if (this.element.classList.contains("scale-reveal")) {
      this.element.style.transform = "translateY(0) scale(1)"
    }
  }
}