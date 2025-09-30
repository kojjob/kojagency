import { Controller } from "@hotwired/stimulus"

// Framer Motion-style animation controller for Rails
export default class extends Controller {
  static targets = ["fadeIn", "slideUp", "slideLeft", "slideRight", "scale", "rotate", "stagger"]
  static values = {
    delay: { type: Number, default: 0 },
    duration: { type: Number, default: 600 },
    staggerDelay: { type: Number, default: 100 }
  }

  connect() {
    this.setupIntersectionObserver()
    this.animateOnLoad()
  }

  setupIntersectionObserver() {
    const options = {
      root: null,
      rootMargin: '0px',
      threshold: 0.1
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          this.animateElement(entry.target)
          this.observer.unobserve(entry.target)
        }
      })
    }, options)

    // Observe all animation targets
    this.observeTargets()
  }

  observeTargets() {
    const allTargets = [
      ...this.fadeInTargets,
      ...this.slideUpTargets,
      ...this.slideLeftTargets,
      ...this.slideRightTargets,
      ...this.scaleTargets,
      ...this.rotateTargets,
      ...this.staggerTargets
    ]

    allTargets.forEach(target => {
      target.style.opacity = '0'
      this.observer.observe(target)
    })
  }

  animateOnLoad() {
    // Trigger immediate animations for above-the-fold content
    setTimeout(() => {
      const immediateElements = this.element.querySelectorAll('[data-animate-immediate]')
      immediateElements.forEach(el => this.animateElement(el))
    }, this.delayValue)
  }

  animateElement(element) {
    const animationType = this.getAnimationType(element)
    const delay = parseInt(element.dataset.delay || this.delayValue)
    const duration = parseInt(element.dataset.duration || this.durationValue)

    setTimeout(() => {
      this.applyAnimation(element, animationType, duration)
    }, delay)
  }

  getAnimationType(element) {
    if (this.fadeInTargets.includes(element)) return 'fadeIn'
    if (this.slideUpTargets.includes(element)) return 'slideUp'
    if (this.slideLeftTargets.includes(element)) return 'slideLeft'
    if (this.slideRightTargets.includes(element)) return 'slideRight'
    if (this.scaleTargets.includes(element)) return 'scale'
    if (this.rotateTargets.includes(element)) return 'rotate'
    if (this.staggerTargets.includes(element)) return 'stagger'
    return 'fadeIn'
  }

  applyAnimation(element, type, duration) {
    element.style.transition = `all ${duration}ms cubic-bezier(0.4, 0, 0.2, 1)`

    switch(type) {
      case 'fadeIn':
        element.style.opacity = '1'
        break
      case 'slideUp':
        element.style.opacity = '1'
        element.style.transform = 'translateY(0)'
        break
      case 'slideLeft':
        element.style.opacity = '1'
        element.style.transform = 'translateX(0)'
        break
      case 'slideRight':
        element.style.opacity = '1'
        element.style.transform = 'translateX(0)'
        break
      case 'scale':
        element.style.opacity = '1'
        element.style.transform = 'scale(1)'
        break
      case 'rotate':
        element.style.opacity = '1'
        element.style.transform = 'rotate(0deg) scale(1)'
        break
      case 'stagger':
        this.applyStaggerAnimation(element)
        break
    }
  }

  applyStaggerAnimation(container) {
    const children = Array.from(container.children)
    children.forEach((child, index) => {
      setTimeout(() => {
        child.style.transition = `all ${this.durationValue}ms cubic-bezier(0.4, 0, 0.2, 1)`
        child.style.opacity = '1'
        child.style.transform = 'translateY(0)'
      }, index * this.staggerDelayValue)
    })
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}