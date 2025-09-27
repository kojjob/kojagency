import { Controller } from "@hotwired/stimulus"

// Category Filter Controller
// Handles dynamic category filtering and interaction
export default class extends Controller {
  static targets = [
    "searchInput",
    "categoriesList",
    "expandedCategories",
    "toggleButton",
    "toggleText",
    "toggleIcon",
    "noResults"
  ]

  connect() {
    console.log("Category filter controller connected")
    this.isExpanded = false
    this.originalCategories = this.getAllCategoryItems()
  }

  toggleExpanded() {
    this.isExpanded = !this.isExpanded

    if (this.isExpanded) {
      this.expandedCategoriesTarget.classList.remove('hidden')
      this.toggleTextTarget.textContent = 'Show Less'
      this.toggleIconTarget.classList.add('rotate-180')

      // Add smooth expand animation
      this.expandedCategoriesTarget.style.height = '0px'
      this.expandedCategoriesTarget.style.overflow = 'hidden'
      this.expandedCategoriesTarget.style.transition = 'height 0.3s ease-out'

      // Force reflow then set to scroll height
      requestAnimationFrame(() => {
        this.expandedCategoriesTarget.style.height = this.expandedCategoriesTarget.scrollHeight + 'px'

        // After animation, remove height constraint
        setTimeout(() => {
          this.expandedCategoriesTarget.style.height = 'auto'
          this.expandedCategoriesTarget.style.overflow = 'visible'
        }, 300)
      })
    } else {
      // Collapse animation
      this.expandedCategoriesTarget.style.height = this.expandedCategoriesTarget.scrollHeight + 'px'
      this.expandedCategoriesTarget.style.overflow = 'hidden'
      this.expandedCategoriesTarget.style.transition = 'height 0.3s ease-in'

      requestAnimationFrame(() => {
        this.expandedCategoriesTarget.style.height = '0px'

        setTimeout(() => {
          this.expandedCategoriesTarget.classList.add('hidden')
          this.expandedCategoriesTarget.style.height = ''
          this.expandedCategoriesTarget.style.overflow = ''
          this.expandedCategoriesTarget.style.transition = ''
        }, 300)
      })

      this.toggleTextTarget.textContent = 'View All'
      this.toggleIconTarget.classList.remove('rotate-180')
    }

    // Track interaction
    this.trackCategoryInteraction('toggle_expanded', { expanded: this.isExpanded })
  }

  filterCategories() {
    const searchTerm = this.searchInputTarget.value.toLowerCase().trim()
    const categoryItems = this.getAllCategoryItems()
    let visibleCount = 0

    categoryItems.forEach(item => {
      const categoryName = item.dataset.categoryName
      const shouldShow = categoryName.includes(searchTerm)

      if (shouldShow) {
        item.style.display = 'block'
        this.animateItemIn(item)
        visibleCount++
      } else {
        this.animateItemOut(item)
      }
    })

    // Show/hide no results message
    if (visibleCount === 0 && searchTerm.length > 0) {
      this.noResultsTarget.classList.remove('hidden')
      this.animateItemIn(this.noResultsTarget)
    } else {
      this.noResultsTarget.classList.add('hidden')
    }

    // Auto-expand if searching
    if (searchTerm.length > 0 && !this.isExpanded) {
      this.toggleExpanded()
    }

    // Track search interaction
    if (searchTerm.length > 2) {
      this.trackCategoryInteraction('search', {
        term: searchTerm,
        results: visibleCount
      })
    }
  }

  animateItemIn(element) {
    element.style.opacity = '0'
    element.style.transform = 'translateY(10px)'
    element.style.transition = 'all 0.2s ease-out'

    requestAnimationFrame(() => {
      element.style.opacity = '1'
      element.style.transform = 'translateY(0)'
    })
  }

  animateItemOut(element) {
    element.style.transition = 'all 0.2s ease-in'
    element.style.opacity = '0'
    element.style.transform = 'translateY(-10px)'

    setTimeout(() => {
      element.style.display = 'none'
    }, 200)
  }

  getAllCategoryItems() {
    return this.categoriesListTarget.querySelectorAll('.category-item')
  }

  // Enhanced interaction tracking
  trackCategoryInteraction(action, data = {}) {
    // Send analytics event
    if (typeof gtag !== 'undefined') {
      gtag('event', 'category_interaction', {
        action: action,
        category: 'blog_categories',
        ...data
      })
    }

    // Console log for debugging
    console.log('Category interaction:', action, data)
  }

  // Handle category link clicks
  categoryClicked(event) {
    const categoryName = event.currentTarget.closest('.category-item')?.dataset.categoryName

    if (categoryName) {
      this.trackCategoryInteraction('category_clicked', {
        category: categoryName,
        source: 'blog_post_sidebar'
      })
    }
  }

  // Clear search and reset view
  clearSearch() {
    this.searchInputTarget.value = ''
    this.filterCategories()
    this.searchInputTarget.focus()
  }

  // Keyboard navigation support
  handleKeydown(event) {
    if (event.target === this.searchInputTarget) {
      switch (event.key) {
        case 'Escape':
          this.clearSearch()
          break
        case 'Enter':
          event.preventDefault()
          // Focus first visible category link
          const firstVisible = this.categoriesListTarget.querySelector('.category-item[style*="display: block"] a, .category-item:not([style*="display: none"]) a')
          if (firstVisible) {
            firstVisible.focus()
          }
          break
      }
    }
  }

  // Handle resize events for responsive behavior
  handleResize() {
    // Debounced resize handling
    clearTimeout(this.resizeTimeout)
    this.resizeTimeout = setTimeout(() => {
      // Reset expanded state on mobile/desktop transitions
      if (window.innerWidth < 768 && this.isExpanded) {
        // Auto-collapse on mobile for better UX
        this.toggleExpanded()
      }
    }, 150)
  }

  disconnect() {
    // Cleanup
    if (this.resizeTimeout) {
      clearTimeout(this.resizeTimeout)
    }

    console.log("Category filter controller disconnected")
  }
}