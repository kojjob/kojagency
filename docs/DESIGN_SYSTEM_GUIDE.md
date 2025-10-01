# Design System Implementation Guide

## Overview
This guide provides instructions for applying the KojAgency Design System across all pages to ensure consistent UI/UX throughout the application.

## Design System Components

### 1. Design System Helper (`app/helpers/design_system_helper.rb`)
Central design tokens and helper methods for consistent styling.

**Key Features:**
- Color palette with gradient-based design
- Typography scale (h1-h6, body sizes)
- Spacing and layout constants
- Reusable helper methods for buttons, cards, badges, icons, forms

### 2. Reusable Component Partials (`app/views/shared/components/`)

#### Button Component (`_button.html.erb`)
**Usage:**
```erb
<%= render "shared/components/button",
    text: "Click Me",
    url: some_path,
    variant: :primary,  # :primary, :secondary, :outline, :ghost, :danger
    size: :xl,          # :sm, :base, :lg, :xl
    icon: true,         # Optional arrow icon
    full_width: false %>
```

**Variants:**
- `:primary` - Gradient primary button (indigo-purple-pink)
- `:secondary` - White button with border
- `:outline` - Transparent with border
- `:ghost` - Transparent, no border
- `:danger` - Red gradient for destructive actions

**Example Before:**
```erb
<%= link_to contact_path, class: "group relative inline-flex items-center justify-center px-10 py-5 bg-gradient-to-r from-indigo-600 via-purple-600 to-pink-600 text-white font-bold rounded-2xl..." do %>
  Start Your Project
<% end %>
```

**Example After:**
```erb
<%= render "shared/components/button",
    text: "Start Your Project",
    url: contact_path,
    variant: :primary,
    size: :xl,
    icon: true %>
```

#### Card Component (`_card.html.erb`)
**Usage:**
```erb
<%= render "shared/components/card",
    variant: :default,     # :default, :gradient_border, :featured
    hover: true,
    padding: :lg do %>      # :sm, :base, :lg
  <!-- Card content here -->
<% end %>
```

**Example:**
```erb
<%= render "shared/components/card", variant: :gradient_border, padding: :lg do %>
  <h3 class="text-2xl font-bold mb-4">Card Title</h3>
  <p>Card content goes here</p>
<% end %>
```

#### Badge Component (`_badge.html.erb`)
**Usage:**
```erb
<%= render "shared/components/badge",
    text: "New",
    color: :indigo,  # :indigo, :green, :yellow, :red, :gray
    size: :base %>   # :sm, :base, :lg
```

#### Icon Container Component (`_icon_container.html.erb`)
**Usage:**
```erb
<%= render "shared/components/icon_container",
    gradient: :primary,  # :primary, :secondary, :success
    size: :lg do %>      # :sm, :base, :lg, :xl
  <!-- SVG icon here -->
  <svg class="w-6 h-6 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="..."></path>
  </svg>
<% end %>
```

#### Section Header Component (`_section_header.html.erb`)
**Usage:**
```erb
<%= render "shared/components/section_header",
    title: "Section <span>Title</span>",  # <span> will get gradient
    subtitle: "Optional description text",
    badge: "Optional Badge",
    gradient: :primary,  # :primary, :secondary, :success
    centered: true %>
```

#### Form Components

**Input Component (`_input.html.erb`):**
```erb
<%= render "shared/components/input",
    form: f,
    field: :email,
    label: "Email Address",
    type: "email",
    required: true,
    placeholder: "you@example.com",
    error: false %>
```

**Textarea Component (`_textarea.html.erb`):**
```erb
<%= render "shared/components/textarea",
    form: f,
    field: :description,
    label: "Description",
    required: true,
    placeholder: "Tell us about your project...",
    rows: 5 %>
```

**Select Component (`_select.html.erb`):**
```erb
<%= render "shared/components/select",
    form: f,
    field: :service_type,
    label: "Service Type",
    options: [["Web Development", "web"], ["Mobile Apps", "mobile"]],
    required: true,
    prompt: "Select a service..." %>
```

## Design System Constants

### Colors
```ruby
COLORS[:primary_gradient]         # Main gradient: indigo-purple-pink
COLORS[:primary_gradient_hover]   # Hover state
COLORS[:secondary_gradient]       # Secondary: purple-pink
COLORS[:accent_gradient]          # Accent: indigo-purple
COLORS[:text_primary]             # Primary text with dark mode
COLORS[:text_secondary]           # Secondary text with dark mode
```

### Typography
```ruby
TYPOGRAPHY[:h1]      # text-5xl lg:text-6xl font-black
TYPOGRAPHY[:h2]      # text-4xl lg:text-5xl font-black
TYPOGRAPHY[:h3]      # text-3xl lg:text-4xl font-bold
TYPOGRAPHY[:body_lg] # text-lg lg:text-xl
TYPOGRAPHY[:lead]    # text-xl lg:text-2xl font-medium
```

### Spacing
```ruby
SPACING[:section]      # py-20 lg:py-32
SPACING[:container]    # max-w-7xl mx-auto px-4 sm:px-6 lg:px-8
SPACING[:card_padding] # p-6 lg:p-8
```

### Border Radius
```ruby
RADIUS[:sm]   # rounded-lg
RADIUS[:base] # rounded-xl
RADIUS[:lg]   # rounded-2xl
RADIUS[:full] # rounded-full
```

## Migration Strategy

### Step 1: Audit Current Pages
Identify all instances of:
- Custom button styles
- Card components
- Form inputs
- Section headers
- Badges and labels

### Step 2: Replace with Components
For each identified element, replace with the appropriate design system component.

### Step 3: Update Helper Usage
Use design system helper methods directly when components aren't suitable:

```erb
<!-- Button without component -->
<button class="<%= button_classes(variant: :primary, size: :lg) %>">
  Click Me
</button>

<!-- Card styling -->
<div class="<%= card_classes(variant: :featured, hover: true) %>">
  Content
</div>
```

### Step 4: Use Background Effects
```erb
<!-- Gradient background effect -->
<section class="relative">
  <%= gradient_bg_effect %>
  <!-- Content -->
</section>

<!-- Grid pattern overlay -->
<section class="relative">
  <%= grid_pattern_overlay(opacity: 5) %>
  <!-- Content -->
</section>
```

## Pages to Update

### High Priority
1. **Landing Page** (`app/views/landing/index.html.erb`) - STARTED
   - ✅ Hero buttons updated
   - ⏳ Stats section cards
   - ⏳ Services section
   - ⏳ Testimonials carousel
   - ⏳ CTA section

2. **Contact Page** (`app/views/landing/contact.html.erb`)
   - Form inputs
   - Submit button
   - Contact cards

3. **Projects Index** (`app/views/projects/index.html.erb`)
   - Project cards
   - Filter buttons
   - Pagination

4. **Project Show** (`app/views/projects/show.html.erb`)
   - Technology badges
   - Testimonial cards
   - CTA buttons

### Medium Priority
5. **Services Index** (`app/views/services/index.html.erb`)
6. **Service Show** (`app/views/services/show.html.erb`)
7. **About Page** (`app/views/landing/about.html.erb`)

### Low Priority
8. **Lead Form** (`app/views/leads/new.html.erb`)
9. **Thank You Page** (`app/views/leads/thank_you.html.erb`)

## Testing Checklist

After applying the design system:
- [ ] Visual consistency across all pages
- [ ] Responsive design on mobile, tablet, desktop
- [ ] Dark mode compatibility (if applicable)
- [ ] Hover states work correctly
- [ ] Focus states for accessibility
- [ ] Form validation styling
- [ ] Button states (loading, disabled)
- [ ] Smooth transitions and animations

## Best Practices

1. **Always use components when available** - Don't recreate button/card styles inline
2. **Maintain gradient consistency** - Use defined color constants
3. **Respect spacing scale** - Use SPACING constants for layout
4. **Typography hierarchy** - Use TYPOGRAPHY constants for text
5. **Accessibility first** - Ensure proper contrast ratios and focus states
6. **Mobile-first** - Test responsive breakpoints
7. **Performance** - Minimize inline styles, use helper methods

## Quick Reference

### Common Patterns

**Hero Section:**
```erb
<section class="relative <%= SPACING[:section_lg] %> bg-gradient-to-br from-indigo-50 via-white to-purple-50">
  <%= gradient_bg_effect %>
  <%= grid_pattern_overlay %>

  <div class="<%= SPACING[:container] %>">
    <%= render "shared/components/section_header",
        title: "Main <span>Headline</span>",
        subtitle: "Supporting text",
        badge: "Badge Text" %>

    <div class="flex gap-4 justify-center">
      <%= render "shared/components/button",
          text: "Primary Action",
          url: path,
          variant: :primary,
          size: :xl %>
    </div>
  </div>
</section>
```

**Card Grid:**
```erb
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
  <% items.each do |item| %>
    <%= render "shared/components/card", variant: :default, hover: true do %>
      <%= render "shared/components/icon_container", gradient: :primary do %>
        <!-- Icon SVG -->
      <% end %>
      <h3 class="<%= TYPOGRAPHY[:h4] %> mt-4">Title</h3>
      <p class="<%= TYPOGRAPHY[:body_base] %> <%= COLORS[:text_secondary] %>">
        Description
      </p>
    <% end %>
  <% end %>
</div>
```

**Form:**
```erb
<%= form_with model: @model do |f| %>
  <%= render "shared/components/input",
      form: f,
      field: :name,
      label: "Full Name",
      required: true %>

  <%= render "shared/components/textarea",
      form: f,
      field: :message,
      label: "Message",
      rows: 5 %>

  <%= render "shared/components/button",
      text: "Submit",
      variant: :primary,
      size: :lg,
      full_width: true %>
<% end %>
```

## Support

For questions or issues with the design system, refer to:
- Design System Helper: `app/helpers/design_system_helper.rb`
- Component Partials: `app/views/shared/components/`
- This Guide: `docs/DESIGN_SYSTEM_GUIDE.md`
