// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Import Active Storage for file attachments
import "@rails/activestorage"

// Import Trix and ActionText for rich text editing
import "trix"
import "@rails/actiontext"

// Import custom Lexxy editor
import "lexxy"

// Initialize rich text editors when the page loads
document.addEventListener("DOMContentLoaded", () => {
  // Ensure Trix is properly initialized
  const initializeTrix = () => {
    document.querySelectorAll("trix-editor").forEach(editor => {
      if (!editor.hasAttribute("data-initialized")) {
        editor.setAttribute("data-initialized", "true");
        console.log("Trix editor found and initialized");
      }
    });
  };

  // Initialize on page load
  initializeTrix();

  // Re-initialize on Turbo navigation
  document.addEventListener("turbo:load", initializeTrix);
  document.addEventListener("turbo:frame-load", initializeTrix);
});
