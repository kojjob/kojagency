import { Controller } from "@hotwired/stimulus"

// Floating Actions Controller
// Handles the smart floating action bar with reading progress and quick actions
export default class extends Controller {
  static targets = ["progressRing", "readingTime"]
  static values = { scrollThreshold: Number }

  connect() {
    this.scrollHandler = this.handleScroll.bind(this)
    this.lastScrollY = 0
    this.isVisible = false

    // Initialize reading progress
    this.updateReadingProgress()

    // Add scroll listener
    window.addEventListener("scroll", this.scrollHandler)

    // Check initial scroll position
    this.handleScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.scrollHandler)
  }

  handleScroll() {
    const currentScrollY = window.scrollY
    const scrollThreshold = this.scrollThresholdValue || 300

    // Show/hide based on scroll position and direction
    if (currentScrollY > scrollThreshold) {
      if (!this.isVisible || currentScrollY < this.lastScrollY) {
        this.show()
      } else if (currentScrollY > this.lastScrollY + 50) {
        // Hide when scrolling down significantly
        this.hide()
      }
    } else {
      this.hide()
    }

    this.lastScrollY = currentScrollY
    this.updateReadingProgress()
    this.updateReadingTimeLeft()
  }

  show() {
    this.isVisible = true
    this.element.classList.remove("opacity-0", "translate-y-20", "pointer-events-none")
    this.element.classList.add("opacity-100", "translate-y-0")
  }

  hide() {
    this.isVisible = false
    this.element.classList.add("opacity-0", "translate-y-20", "pointer-events-none")
    this.element.classList.remove("opacity-100", "translate-y-0")
  }

  updateReadingProgress() {
    if (!this.hasProgressRingTarget) return

    const windowHeight = window.innerHeight
    const documentHeight = document.documentElement.scrollHeight
    const scrolled = window.scrollY
    const progress = Math.min(100, (scrolled / (documentHeight - windowHeight)) * 100)

    // Update progress ring (SVG circle circumference is ~126)
    const circumference = 126
    const offset = circumference - (progress / 100) * circumference
    this.progressRingTarget.style.strokeDashoffset = offset
  }

  updateReadingTimeLeft() {
    if (!this.hasReadingTimeTarget) return

    const windowHeight = window.innerHeight
    const documentHeight = document.documentElement.scrollHeight
    const scrolled = window.scrollY
    const progress = (scrolled / (documentHeight - windowHeight))

    // Get initial reading time from the element
    const totalReadingTime = parseInt(this.readingTimeTarget.dataset.totalTime || 5)
    const timeLeft = Math.ceil(totalReadingTime * (1 - progress))

    this.readingTimeTarget.textContent = Math.max(0, timeLeft)
  }

  // Action button handlers
  scrollToTop(event) {
    event.preventDefault()
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  share(event) {
    event.preventDefault()

    if (navigator.share) {
      navigator.share({
        title: document.title,
        text: document.querySelector('meta[name="description"]')?.content,
        url: window.location.href
      }).catch((err) => console.log('Share cancelled:', err))
    } else {
      // Fallback to copy URL
      navigator.clipboard.writeText(window.location.href)
      this.showToast("Link copied to clipboard!")
    }
  }

  bookmark(event) {
    event.preventDefault()

    // Check if already bookmarked (using localStorage)
    const bookmarks = JSON.parse(localStorage.getItem('bookmarks') || '[]')
    const currentUrl = window.location.href
    const bookmarkIndex = bookmarks.findIndex(b => b.url === currentUrl)

    if (bookmarkIndex === -1) {
      // Add bookmark
      bookmarks.push({
        url: currentUrl,
        title: document.title,
        date: new Date().toISOString()
      })
      event.currentTarget.querySelector('i').classList.replace('far', 'fas')
      this.showToast("Page bookmarked!")
    } else {
      // Remove bookmark
      bookmarks.splice(bookmarkIndex, 1)
      event.currentTarget.querySelector('i').classList.replace('fas', 'far')
      this.showToast("Bookmark removed")
    }

    localStorage.setItem('bookmarks', JSON.stringify(bookmarks))
  }

  adjustFontSize(event) {
    event.preventDefault()

    const article = document.querySelector('.article-content')
    if (!article) return

    const currentSize = parseFloat(window.getComputedStyle(article).fontSize)
    const sizes = [14, 16, 18, 20, 22]
    const currentIndex = sizes.findIndex(size => size >= currentSize)
    const nextIndex = (currentIndex + 1) % sizes.length

    article.style.fontSize = `${sizes[nextIndex]}px`
    this.showToast(`Font size: ${sizes[nextIndex]}px`)
  }

  showToast(message) {
    // Create toast element
    const toast = document.createElement('div')
    toast.className = 'fixed bottom-24 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white px-6 py-3 rounded-full text-sm font-medium shadow-lg z-50 transition-all duration-300 opacity-0 translate-y-4'
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
}