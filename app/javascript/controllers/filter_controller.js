import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "item"]

  connect() {
    // Set initial active tab
    this.filterBy("All")
  }

  filter(event) {
    const category = event.currentTarget.dataset.category
    this.filterBy(category)
  }

  filterBy(category) {
    // Update active tab styling
    this.tabTargets.forEach(tab => {
      if (tab.dataset.category === category) {
        tab.classList.add("bg-indigo-600", "text-white")
        tab.classList.remove("bg-gray-100", "text-gray-700", "hover:bg-gray-200")
      } else {
        tab.classList.remove("bg-indigo-600", "text-white")
        tab.classList.add("bg-gray-100", "text-gray-700", "hover:bg-gray-200")
      }
    })

    // Show/hide items based on category
    this.itemTargets.forEach(item => {
      const itemCategory = item.dataset.category

      if (category === "All" || itemCategory === category) {
        // Show item with animation
        item.style.display = ""
        setTimeout(() => {
          item.classList.remove("opacity-0", "scale-95")
          item.classList.add("opacity-100", "scale-100")
        }, 10)
      } else {
        // Hide item with animation
        item.classList.add("opacity-0", "scale-95")
        item.classList.remove("opacity-100", "scale-100")
        setTimeout(() => {
          item.style.display = "none"
        }, 300)
      }
    })

    // If no items match, show a message
    const visibleItems = this.itemTargets.filter(item =>
      category === "All" || item.dataset.category === category
    )

    if (visibleItems.length === 0) {
      this.showNoResultsMessage(category)
    } else {
      this.hideNoResultsMessage()
    }
  }

  showNoResultsMessage(category) {
    const container = this.element.querySelector("#projects-grid")
    if (!container) return

    let message = container.querySelector(".no-results-message")
    if (!message) {
      message = document.createElement("div")
      message.className = "no-results-message col-span-full text-center py-12"
      message.innerHTML = `
        <div class="text-gray-500">
          <svg class="mx-auto h-12 w-12 text-gray-400 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.172 16.172a4 4 0 015.656 0M9 10h.01M15 10h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"></path>
          </svg>
          <p class="text-lg">No projects found in the "${category}" category.</p>
          <p class="text-sm mt-2">Try selecting a different category or view all projects.</p>
        </div>
      `
      container.appendChild(message)
    }
    message.style.display = ""
  }

  hideNoResultsMessage() {
    const message = this.element.querySelector(".no-results-message")
    if (message) {
      message.style.display = "none"
    }
  }
}