import { Controller } from "@hotwired/stimulus"
import { LexxyEditor } from "lexxy"

// Connects to data-controller="lexxy"
export default class extends Controller {
  static targets = ["editor"]
  static values = { config: Object }

  connect() {
    this.initializeLexxy()
  }

  disconnect() {
    if (this.editor) {
      this.editor.destroy()
    }
  }

  initializeLexxy() {
    const editorElement = this.editorTarget
    const config = this.configValue || {}

    // Default configuration
    const defaultConfig = {
      toolbar: true,
      placeholder: "Start writing...",
      features: {
        markdown: true,
        mentions: false,
        links: true,
        formatting: true
      }
    }

    // Merge with custom config
    const finalConfig = { ...defaultConfig, ...config }

    // Initialize Lexxy editor
    this.editor = new LexxyEditor(editorElement, finalConfig)
  }
}