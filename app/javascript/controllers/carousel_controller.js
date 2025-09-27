import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "slide"]

  connect() {
    this.currentIndex = 0
    this.totalSlides = this.slideTargets.length

    // Auto-play carousel
    this.startAutoPlay()

    // Pause on hover
    this.element.addEventListener("mouseenter", () => this.stopAutoPlay())
    this.element.addEventListener("mouseleave", () => this.startAutoPlay())
  }

  disconnect() {
    this.stopAutoPlay()
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.totalSlides
    this.updateSlide()
  }

  prev() {
    this.currentIndex = (this.currentIndex - 1 + this.totalSlides) % this.totalSlides
    this.updateSlide()
  }

  goToSlide(event) {
    const index = parseInt(event.params.slide)
    if (index >= 0 && index < this.totalSlides) {
      this.currentIndex = index
      this.updateSlide()
    }
  }

  updateSlide() {
    const offset = -this.currentIndex * 100
    this.containerTarget.style.transform = `translateX(${offset}%)`

    // Update dots
    this.element.querySelectorAll("[data-carousel-slide-param]").forEach((dot, index) => {
      if (index === this.currentIndex) {
        dot.classList.add("w-8", "bg-indigo-600")
        dot.classList.remove("w-2", "bg-gray-300")
      } else {
        dot.classList.remove("w-8", "bg-indigo-600")
        dot.classList.add("w-2", "bg-gray-300")
      }
    })
  }

  startAutoPlay() {
    this.autoPlayInterval = setInterval(() => {
      this.next()
    }, 5000) // Change slide every 5 seconds
  }

  stopAutoPlay() {
    if (this.autoPlayInterval) {
      clearInterval(this.autoPlayInterval)
      this.autoPlayInterval = null
    }
  }
}