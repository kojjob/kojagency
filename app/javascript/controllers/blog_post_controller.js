import { Controller } from "@hotwired/stimulus"

// Blog Post Stimulus Controller
// Handles social sharing, table of contents, and reading progress
export default class extends Controller {
  static targets = ["tocList", "articleContent", "readingProgress", "postTitle"]
  static values = { title: String }

  connect() {
    this.initTableOfContents()
    this.initReadingProgress()
  }

  // Social Share Actions
  shareOnTwitter() {
    const url = encodeURIComponent(window.location.href)
    const text = encodeURIComponent(this.titleValue || this.postTitleTarget.textContent)
    window.open(`https://twitter.com/intent/tweet?url=${url}&text=${text}`, '_blank', 'width=600,height=400')
  }

  shareOnLinkedIn() {
    const url = encodeURIComponent(window.location.href)
    window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${url}`, '_blank', 'width=600,height=400')
  }

  shareOnFacebook() {
    const url = encodeURIComponent(window.location.href)
    window.open(`https://www.facebook.com/sharer/sharer.php?u=${url}`, '_blank', 'width=600,height=400')
  }

  copyLink(event) {
    navigator.clipboard.writeText(window.location.href).then(() => {
      // Show a temporary toast notification
      const button = event.currentTarget
      const originalText = button.querySelector('span').textContent
      button.querySelector('span').textContent = 'Copied!'
      button.classList.add('bg-green-600', 'hover:bg-green-700')
      button.classList.remove('bg-gray-600', 'hover:bg-gray-700')

      setTimeout(() => {
        button.querySelector('span').textContent = originalText
        button.classList.remove('bg-green-600', 'hover:bg-green-700')
        button.classList.add('bg-gray-600', 'hover:bg-gray-700')
      }, 2000)
    })
  }

  // Table of Contents Generation
  initTableOfContents() {
    if (!this.hasTocListTarget || !this.hasArticleContentTarget) return

    const headings = this.articleContentTarget.querySelectorAll('h2, h3')

    if (headings.length > 0) {
      headings.forEach((heading, index) => {
        // Give each heading an ID for linking
        if (!heading.id) {
          heading.id = 'heading-' + index
        }

        // Create TOC item
        const li = document.createElement('li')
        const a = document.createElement('a')
        a.href = '#' + heading.id
        a.textContent = heading.textContent
        a.className = heading.tagName === 'H2'
          ? 'block py-2 px-3 text-sm text-gray-700 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition-all'
          : 'block py-2 pl-6 pr-3 text-sm text-gray-600 hover:text-indigo-600 hover:bg-indigo-50 rounded-lg transition-all'

        // Smooth scroll on click
        a.addEventListener('click', (e) => {
          e.preventDefault()
          document.getElementById(heading.id).scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          })

          // Update active state
          this.updateActiveLink(a)
        })

        li.appendChild(a)
        this.tocListTarget.appendChild(li)
      })

      // Highlight active section on scroll
      this.initScrollObserver(headings)
    } else {
      // No headings found
      this.tocListTarget.innerHTML = '<li class="text-sm text-gray-500 italic">No sections available</li>'
    }
  }

  updateActiveLink(activeLink) {
    this.tocListTarget.querySelectorAll('a').forEach(link => {
      link.classList.remove('active', 'bg-indigo-50', 'text-indigo-600', 'font-medium')
    })
    activeLink.classList.add('active', 'bg-indigo-50', 'text-indigo-600', 'font-medium')
  }

  initScrollObserver(headings) {
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const id = entry.target.id
          this.tocListTarget.querySelectorAll('a').forEach(link => {
            link.classList.remove('active', 'bg-indigo-50', 'text-indigo-600', 'font-medium')
            if (link.getAttribute('href') === '#' + id) {
              link.classList.add('active', 'bg-indigo-50', 'text-indigo-600', 'font-medium')
            }
          })
        }
      })
    }, { rootMargin: '-20% 0px -70% 0px' })

    headings.forEach(heading => observer.observe(heading))
  }

  // Reading Progress Bar
  initReadingProgress() {
    if (!this.hasReadingProgressTarget || !this.hasArticleContentTarget) return

    window.addEventListener('scroll', () => {
      const articleRect = this.articleContentTarget.getBoundingClientRect()
      const articleHeight = articleRect.height
      const windowHeight = window.innerHeight
      const scrolled = window.scrollY - articleRect.top - document.body.scrollTop
      const progress = Math.max(0, Math.min(100, (scrolled / (articleHeight - windowHeight)) * 100))
      this.readingProgressTarget.style.width = progress + '%'
    })
  }
}