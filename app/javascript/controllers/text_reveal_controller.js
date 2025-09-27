import { Controller } from "@hotwired/stimulus"

// Text Reveal Controller
// Handles animated text reveals on scroll
export default class extends Controller {
  static values = {
    delay: { type: Number, default: 100 },
    threshold: { type: Number, default: 0.2 }
  }

  connect() {
    this.revealed = false
    this.setupObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  setupObserver() {
    const options = {
      threshold: this.thresholdValue,
      rootMargin: '0px 0px -50px 0px'
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting && !this.revealed) {
          this.reveal()
        }
      })
    }, options)

    this.observer.observe(this.element)
  }

  reveal() {
    this.revealed = true

    // Check if element has words to split
    const text = this.element.textContent.trim()
    if (!text) return

    // Split text into words and wrap each in a span
    const words = text.split(' ')
    const wrappedWords = words.map((word, index) => {
      const delay = index * this.delayValue
      return `<span class="inline-block opacity-0 transform translate-y-4 transition-all duration-700 ease-out"
                    style="transition-delay: ${delay}ms">${word}</span>`
    })

    // Replace content with wrapped words
    this.element.innerHTML = wrappedWords.join(' ')

    // Trigger animation after a small delay
    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        const spans = this.element.querySelectorAll('span')
        spans.forEach(span => {
          span.classList.remove('opacity-0', 'translate-y-4')
          span.classList.add('opacity-100', 'translate-y-0')
        })
      })
    })
  }

  // Alternative reveal for elements that shouldn't be split
  simpleReveal() {
    this.element.classList.remove('opacity-0', 'translate-y-8')
    this.element.classList.add('opacity-100', 'translate-y-0')
  }
}