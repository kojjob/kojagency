import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Add parallax effect to hero section
    this.handleParallax = this.handleParallax.bind(this)
    window.addEventListener("scroll", this.handleParallax, { passive: true })

    // Animate elements on load
    this.animateElements()
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleParallax)
  }

  handleParallax() {
    const scrollY = window.scrollY
    const heroHeight = this.element.offsetHeight

    // Only apply parallax when hero is visible
    if (scrollY < heroHeight) {
      // Parallax effect for background blobs
      const blobs = this.element.querySelectorAll(".animate-blob")
      blobs.forEach((blob, index) => {
        const speed = 0.5 + (index * 0.1)
        blob.style.transform = `translateY(${scrollY * speed}px)`
      })

      // Fade out content on scroll
      const content = this.element.querySelector(".relative.z-10")
      if (content) {
        const opacity = Math.max(0, 1 - (scrollY / (heroHeight * 0.8)))
        content.style.opacity = opacity
        content.style.transform = `translateY(${scrollY * 0.3}px)`
      }
    }
  }

  animateElements() {
    // Stagger animation for hero content
    const elements = this.element.querySelectorAll(".animate-fadeInUp")
    elements.forEach((element, index) => {
      element.style.opacity = "0"
      element.style.transform = "translateY(30px)"

      setTimeout(() => {
        element.style.transition = "opacity 0.6s ease-out, transform 0.6s ease-out"
        element.style.opacity = "1"
        element.style.transform = "translateY(0)"
      }, index * 100)
    })
  }
}