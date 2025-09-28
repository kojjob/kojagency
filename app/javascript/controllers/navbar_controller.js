import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["mobileMenu", "openIcon", "closeIcon", "menuButton", "searchInput"]

  connect() {
    console.log('Navbar controller connected!')

    // Initialize dark mode from localStorage
    this.initDarkMode()

    // Handle scroll behavior with hide/show
    this.lastScrollTop = 0
    this.scrollThreshold = 100
    this.handleScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.handleScroll, { passive: true })

    // Set active page indicator
    this.setActivePageIndicator()

    // Initial scroll check
    this.handleScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.handleScroll)
  }

  // Dark mode functionality
  initDarkMode() {
    const darkMode = localStorage.getItem('darkMode') === 'true'
    if (darkMode) {
      document.documentElement.classList.add('dark')
    }
  }

  toggleDarkMode() {
    console.log('Dark mode toggle clicked')
    const isDark = document.documentElement.classList.toggle('dark')
    localStorage.setItem('darkMode', isDark)
    console.log('Dark mode is now:', isDark ? 'enabled' : 'disabled')

    // Animate the toggle icon
    const icon = event.currentTarget.querySelector('svg')
    if (icon) {
      icon.classList.add('rotate-180', 'scale-110')
      setTimeout(() => {
        icon.classList.remove('rotate-180', 'scale-110')
      }, 300)
    }
  }

  // Mobile menu functionality
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

  // Enhanced scroll behavior with hide/show
  handleScroll() {
    const currentScroll = window.pageYOffset || document.documentElement.scrollTop
    const navbar = this.element

    // Add/remove background and shadow based on scroll position
    if (currentScroll > 10) {
      navbar.classList.add("bg-white/98", "shadow-md", "backdrop-blur-xl")
      navbar.classList.remove("bg-white/95")
    } else {
      navbar.classList.add("bg-white/95")
      navbar.classList.remove("bg-white/98", "shadow-md")
    }

    // Hide/show navbar on scroll direction
    if (currentScroll > this.lastScrollTop && currentScroll > this.scrollThreshold) {
      // Scrolling down & past threshold - hide navbar
      navbar.style.transform = 'translateY(-100%)'
      navbar.classList.add('transition-transform', 'duration-300')
    } else {
      // Scrolling up or at top - show navbar
      navbar.style.transform = 'translateY(0)'
      navbar.classList.add('transition-transform', 'duration-300')
    }

    // Prevent negative scroll values
    this.lastScrollTop = currentScroll <= 0 ? 0 : currentScroll
  }

  // Active page indicator
  setActivePageIndicator() {
    const currentPath = window.location.pathname
    const navLinks = this.element.querySelectorAll('nav a[href]')

    navLinks.forEach(link => {
      // Skip external links and hash links
      if (link.hostname !== window.location.hostname || link.getAttribute('href').startsWith('#')) {
        return
      }

      const linkPath = new URL(link.href).pathname
      const linkUnderline = link.querySelector('span.absolute')

      // Check if this is the active page
      const isActive = currentPath === linkPath ||
                      (linkPath !== '/' && currentPath.startsWith(linkPath))

      if (isActive) {
        // Add active styles
        link.classList.add('text-indigo-600', 'font-semibold')
        link.classList.remove('text-gray-700')

        // Show underline for active page
        if (linkUnderline) {
          linkUnderline.classList.remove('scale-x-0')
          linkUnderline.classList.add('scale-x-100')
        }
      } else {
        // Remove active styles
        link.classList.remove('text-indigo-600', 'font-semibold')
        link.classList.add('text-gray-700')

        // Hide underline for inactive pages
        if (linkUnderline && !link.matches(':hover')) {
          linkUnderline.classList.add('scale-x-0')
          linkUnderline.classList.remove('scale-x-100')
        }
      }
    })
  }

  // Search functionality
  expandSearch(event) {
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.classList.remove('w-10')
      this.searchInputTarget.classList.add('w-64')
      this.searchInputTarget.focus()
    }
  }

  collapseSearch(event) {
    if (this.hasSearchInputTarget && !event.target.value) {
      this.searchInputTarget.classList.add('w-10')
      this.searchInputTarget.classList.remove('w-64')
    }
  }

  handleSearch(event) {
    if (event.key === 'Enter') {
      const query = event.target.value.trim()
      if (query) {
        // Implement search logic - redirect to search page
        window.location.href = `/search?q=${encodeURIComponent(query)}`
      }
    }
  }
}