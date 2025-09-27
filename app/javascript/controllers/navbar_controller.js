import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "openIcon", "closeIcon", "menuButton"]

  connect() {
    // Handle scroll behavior
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll)

    // Initial check
    this.handleScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  toggleMobile() {
    const isOpen = !this.mobileMenuTarget.classList.contains("hidden")

    if (isOpen) {
      this.closeMobile()
    } else {
      this.openMobile()
    }
  }

  openMobile() {
    this.mobileMenuTarget.classList.remove("hidden")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")

    // Animate menu
    requestAnimationFrame(() => {
      this.mobileMenuTarget.classList.add("animate-slideDown")
    })
  }

  closeMobile() {
    this.mobileMenuTarget.classList.add("hidden")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }

  handleScroll() {
    const scrollY = window.scrollY
    const navbar = this.element

    if (scrollY > 50) {
      navbar.classList.add("shadow-lg", "bg-white")
      navbar.classList.remove("bg-white/90")
    } else {
      navbar.classList.remove("shadow-lg")
      navbar.classList.add("bg-white/90")
    }
  }
}