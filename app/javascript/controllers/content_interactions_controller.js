import { Controller } from "@hotwired/stimulus"

// Content Interactions Controller
// Handles interactive content features like text selection sharing
export default class extends Controller {
  static targets = ["tooltip"]

  connect() {
    this.selectedText = ""
    this.tooltipTimeout = null

    // Add event listeners for text selection
    this.element.addEventListener("mouseup", this.handleSelection.bind(this))
    this.element.addEventListener("touchend", this.handleSelection.bind(this))

    // Hide tooltip on click outside
    document.addEventListener("click", this.hideTooltip.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("mouseup", this.handleSelection)
    this.element.removeEventListener("touchend", this.handleSelection)
    document.removeEventListener("click", this.hideTooltip)

    if (this.tooltipTimeout) {
      clearTimeout(this.tooltipTimeout)
    }
  }

  handleSelection(event) {
    // Delay to ensure selection is complete
    setTimeout(() => {
      const selection = window.getSelection()
      const text = selection.toString().trim()

      if (text && text.length > 5) {
        this.selectedText = text
        this.showShareTooltip(event, selection)
      } else {
        this.hideTooltip()
      }
    }, 10)
  }

  showShareTooltip(event, selection) {
    // Get selection coordinates
    const range = selection.getRangeAt(0)
    const rect = range.getBoundingClientRect()

    // Create or get tooltip
    let tooltip = this.tooltip
    if (!tooltip) {
      tooltip = this.createTooltip()
      this.tooltip = tooltip
    }

    // Position tooltip above selection
    tooltip.style.position = 'fixed'
    tooltip.style.left = `${rect.left + rect.width / 2}px`
    tooltip.style.top = `${rect.top - 10}px`
    tooltip.style.transform = 'translate(-50%, -100%)'

    // Show tooltip with animation
    document.body.appendChild(tooltip)

    requestAnimationFrame(() => {
      tooltip.classList.remove('opacity-0', 'scale-95')
      tooltip.classList.add('opacity-100', 'scale-100')
    })
  }

  createTooltip() {
    const tooltip = document.createElement('div')
    tooltip.className = 'bg-gray-900 dark:bg-gray-800 text-white rounded-lg px-2 py-1 flex items-center space-x-1 shadow-lg transition-all duration-200 opacity-0 scale-95 z-50'
    tooltip.innerHTML = `
      <button class="p-1.5 hover:bg-gray-800 dark:hover:bg-gray-700 rounded transition-colors" data-action="click->content-interactions#shareTwitter">
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
          <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
        </svg>
      </button>
      <button class="p-1.5 hover:bg-gray-800 dark:hover:bg-gray-700 rounded transition-colors" data-action="click->content-interactions#shareLinkedIn">
        <svg class="w-4 h-4" fill="currentColor" viewBox="0 0 24 24">
          <path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z"/>
        </svg>
      </button>
      <button class="p-1.5 hover:bg-gray-800 dark:hover:bg-gray-700 rounded transition-colors" data-action="click->content-interactions#copyText">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 16H6a2 2 0 01-2-2V6a2 2 0 012-2h8a2 2 0 012 2v2m-6 12h8a2 2 0 002-2v-8a2 2 0 00-2-2h-8a2 2 0 00-2 2v8a2 2 0 002 2z"/>
        </svg>
      </button>
      <button class="p-1.5 hover:bg-gray-800 dark:hover:bg-gray-700 rounded transition-colors" data-action="click->content-interactions#highlightText">
        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z"/>
        </svg>
      </button>
    `

    // Store controller reference for event handling
    tooltip.dataset.controller = "content-interactions"

    return tooltip
  }

  hideTooltip(event) {
    if (!this.tooltip) return

    // Don't hide if clicking on the tooltip itself
    if (event && this.tooltip.contains(event.target)) return

    this.tooltip.classList.add('opacity-0', 'scale-95')
    this.tooltip.classList.remove('opacity-100', 'scale-100')

    setTimeout(() => {
      if (this.tooltip.parentNode) {
        this.tooltip.parentNode.removeChild(this.tooltip)
      }
    }, 200)
  }

  shareTwitter(event) {
    event.preventDefault()
    const text = encodeURIComponent(`"${this.selectedText}"`)
    const url = encodeURIComponent(window.location.href)
    window.open(`https://twitter.com/intent/tweet?text=${text}&url=${url}`, '_blank', 'width=600,height=400')
    this.hideTooltip()
  }

  shareLinkedIn(event) {
    event.preventDefault()
    const url = encodeURIComponent(window.location.href)
    window.open(`https://www.linkedin.com/sharing/share-offsite/?url=${url}`, '_blank', 'width=600,height=400')
    this.hideTooltip()
  }

  copyText(event) {
    event.preventDefault()
    navigator.clipboard.writeText(this.selectedText)
    this.showToast("Text copied to clipboard!")
    this.hideTooltip()
  }

  highlightText(event) {
    event.preventDefault()

    // Wrap selected text in a highlight span
    const selection = window.getSelection()
    if (selection.rangeCount > 0) {
      const range = selection.getRangeAt(0)

      // Create highlight wrapper
      const highlight = document.createElement('mark')
      highlight.className = 'bg-yellow-200 dark:bg-yellow-800 text-gray-900 dark:text-gray-100 px-1 rounded'

      try {
        range.surroundContents(highlight)
      } catch (e) {
        // If surroundContents fails (e.g., across multiple elements), use alternative method
        const contents = range.extractContents()
        highlight.appendChild(contents)
        range.insertNode(highlight)
      }

      // Save highlight to localStorage for persistence
      this.saveHighlight(highlight)
    }

    selection.removeAllRanges()
    this.hideTooltip()
    this.showToast("Text highlighted!")
  }

  saveHighlight(element) {
    // Save highlights to localStorage for the current page
    const highlights = JSON.parse(localStorage.getItem('highlights') || '{}')
    const pageHighlights = highlights[window.location.pathname] || []

    pageHighlights.push({
      text: element.textContent,
      timestamp: new Date().toISOString()
    })

    highlights[window.location.pathname] = pageHighlights
    localStorage.setItem('highlights', JSON.stringify(highlights))
  }

  showToast(message) {
    const toast = document.createElement('div')
    toast.className = 'fixed bottom-8 left-1/2 transform -translate-x-1/2 bg-gray-900 text-white px-4 py-2 rounded-lg text-sm font-medium shadow-lg z-50 transition-all duration-300 opacity-0 translate-y-4'
    toast.textContent = message

    document.body.appendChild(toast)

    requestAnimationFrame(() => {
      toast.classList.remove('opacity-0', 'translate-y-4')
      toast.classList.add('opacity-100', 'translate-y-0')
    })

    setTimeout(() => {
      toast.classList.add('opacity-0', 'translate-y-4')
      toast.classList.remove('opacity-100', 'translate-y-0')
      setTimeout(() => toast.remove(), 300)
    }, 2000)
  }
}