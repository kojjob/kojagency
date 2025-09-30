import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    // Ensure Trix is loaded
    if (typeof Trix === 'undefined') {
      console.error('Trix is not loaded')
      return
    }

    // Initialize Trix editor
    const editor = this.element

    // Set up the toolbar if it exists
    const toolbar = editor.previousElementSibling
    if (toolbar && toolbar.tagName === 'TRIX-TOOLBAR') {
      editor.setAttribute('toolbar', toolbar.id || 'trix-toolbar')
    }

    // Ensure the editor is properly initialized
    if (!editor.editor) {
      // Force initialization
      editor.addEventListener('trix-initialize', () => {
        console.log('Trix editor initialized')
      })
    }

    // Handle content changes
    editor.addEventListener('trix-change', (event) => {
      const input = document.querySelector(`input[name="${editor.getAttribute('input')}"]`)
      if (input) {
        input.value = editor.editor.getDocument().toString()
      }
    })

    // Add custom toolbar actions if needed
    this.setupCustomActions()
  }

  setupCustomActions() {
    // Add any custom toolbar actions here
    const editor = this.element

    // Example: Add a custom button for inserting code blocks
    editor.addEventListener('trix-initialize', () => {
      const toolbar = editor.toolbarElement
      if (toolbar) {
        // Custom toolbar modifications can go here
      }
    })
  }

  disconnect() {
    // Clean up event listeners if needed
  }
}