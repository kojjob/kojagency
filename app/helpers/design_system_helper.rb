# frozen_string_literal: true

module DesignSystemHelper
  # Design System Configuration for KojAgency
  # Ensures consistent UI/UX across all pages

  # Color Palette - Gradient-based design
  COLORS = {
    # Primary gradients
    primary_gradient: "from-indigo-600 via-purple-600 to-pink-600",
    primary_gradient_hover: "from-indigo-700 via-purple-700 to-pink-700",
    primary_gradient_light: "from-indigo-50 via-purple-50 to-pink-50",

    # Secondary gradients
    secondary_gradient: "from-purple-500 to-pink-500",
    accent_gradient: "from-indigo-500 to-purple-500",
    success_gradient: "from-green-500 to-emerald-500",
    warning_gradient: "from-yellow-400 to-orange-500",
    danger_gradient: "from-red-500 to-pink-500",

    # Background effects
    bg_glow: "from-indigo-500 via-purple-500 to-pink-500",
    bg_subtle: "from-gray-50 to-indigo-50",

    # Text colors
    text_primary: "text-gray-900 dark:text-gray-100",
    text_secondary: "text-gray-600 dark:text-gray-400",
    text_muted: "text-gray-500 dark:text-gray-500"
  }.freeze

  # Typography Scale
  TYPOGRAPHY = {
    # Headings
    h1: "text-5xl lg:text-6xl font-black",
    h2: "text-4xl lg:text-5xl font-black",
    h3: "text-3xl lg:text-4xl font-bold",
    h4: "text-2xl lg:text-3xl font-bold",
    h5: "text-xl lg:text-2xl font-semibold",
    h6: "text-lg lg:text-xl font-semibold",

    # Body text
    body_xl: "text-xl lg:text-2xl",
    body_lg: "text-lg lg:text-xl",
    body_base: "text-base lg:text-lg",
    body_sm: "text-sm lg:text-base",

    # Special
    display: "text-6xl lg:text-7xl font-black",
    lead: "text-xl lg:text-2xl font-medium"
  }.freeze

  # Spacing Scale
  SPACING = {
    section: "py-20 lg:py-32",
    section_sm: "py-12 lg:py-20",
    section_lg: "py-32 lg:py-40",
    container: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8",
    card_padding: "p-6 lg:p-8",
    card_padding_lg: "p-8 lg:p-12"
  }.freeze

  # Border Radius
  RADIUS = {
    sm: "rounded-lg",
    base: "rounded-xl",
    lg: "rounded-2xl",
    xl: "rounded-3xl",
    full: "rounded-full"
  }.freeze

  # Shadow Styles
  SHADOWS = {
    sm: "shadow-sm",
    base: "shadow-lg",
    lg: "shadow-2xl",
    glow: "shadow-2xl shadow-indigo-500/20",
    hover: "hover:shadow-2xl"
  }.freeze

  # Button Styles
  def button_classes(variant: :primary, size: :base, full_width: false)
    base_classes = "inline-flex items-center justify-center font-bold transition-all duration-300 transform focus:outline-none focus:ring-2 focus:ring-offset-2"

    size_classes = case size
    when :sm
      "px-4 py-2 text-sm #{RADIUS[:base]}"
    when :lg
      "px-8 py-4 text-lg #{RADIUS[:lg]}"
    when :xl
      "px-10 py-5 text-xl #{RADIUS[:lg]}"
    else
      "px-6 py-3 text-base #{RADIUS[:lg]}"
    end

    variant_classes = case variant
    when :primary
      "bg-gradient-to-r #{COLORS[:primary_gradient]} text-white hover:#{COLORS[:primary_gradient_hover]} #{SHADOWS[:hover]} hover:-translate-y-1 focus:ring-indigo-500"
    when :secondary
      "bg-white text-indigo-600 border-2 border-indigo-600 hover:bg-indigo-50 #{SHADOWS[:hover]} hover:-translate-y-1 focus:ring-indigo-500"
    when :outline
      "bg-transparent border-2 border-gray-300 #{COLORS[:text_primary]} hover:border-indigo-600 hover:bg-indigo-50 focus:ring-indigo-500"
    when :ghost
      "bg-transparent #{COLORS[:text_primary]} hover:bg-gray-100 dark:hover:bg-gray-800"
    when :danger
      "bg-gradient-to-r #{COLORS[:danger_gradient]} text-white #{SHADOWS[:hover]} hover:-translate-y-1 focus:ring-red-500"
    end

    width_class = full_width ? "w-full" : ""

    "#{base_classes} #{size_classes} #{variant_classes} #{width_class}"
  end

  # Card Styles
  def card_classes(variant: :default, hover: true)
    base_classes = "bg-white dark:bg-gray-800 #{RADIUS[:lg]} #{SHADOWS[:base]} border border-gray-100 dark:border-gray-700"
    hover_classes = hover ? "transition-all duration-300 hover:#{SHADOWS[:glow]} hover:border-indigo-200 hover:-translate-y-1" : ""

    case variant
    when :gradient_border
      "relative group #{base_classes} #{hover_classes}"
    when :featured
      "#{base_classes} #{hover_classes} border-2 border-indigo-500"
    else
      "#{base_classes} #{hover_classes}"
    end
  end

  # Badge Styles
  def badge_classes(color: :indigo, size: :base)
    size_classes = case size
    when :sm
      "px-2 py-1 text-xs"
    when :lg
      "px-4 py-2 text-base"
    else
      "px-3 py-1 text-sm"
    end

    color_classes = case color
    when :indigo
      "bg-gradient-to-r from-indigo-500 to-purple-500 text-white"
    when :green
      "bg-gradient-to-r from-green-500 to-emerald-500 text-white"
    when :yellow
      "bg-gradient-to-r from-yellow-400 to-orange-500 text-white"
    when :red
      "bg-gradient-to-r from-red-500 to-pink-500 text-white"
    when :gray
      "bg-gray-100 text-gray-700 dark:bg-gray-700 dark:text-gray-300"
    end

    "#{size_classes} #{color_classes} #{RADIUS[:full]} font-bold #{SHADOWS[:sm]}"
  end

  # Icon Container Styles
  def icon_container_classes(gradient: :primary, size: :base)
    size_classes = case size
    when :sm
      "w-8 h-8"
    when :lg
      "w-14 h-14"
    when :xl
      "w-16 h-16"
    else
      "w-10 h-10"
    end

    gradient_classes = case gradient
    when :primary
      "bg-gradient-to-br #{COLORS[:accent_gradient]}"
    when :secondary
      "bg-gradient-to-br #{COLORS[:secondary_gradient]}"
    when :success
      "bg-gradient-to-br #{COLORS[:success_gradient]}"
    end

    "#{size_classes} #{gradient_classes} #{RADIUS[:lg]} flex items-center justify-center #{SHADOWS[:base]} transform group-hover:scale-110 transition-transform duration-300"
  end

  # Section Header Component
  def section_header(title:, subtitle: nil, badge: nil, gradient: :primary)
    gradient_text = case gradient
    when :primary
      "from-gray-900 via-indigo-600 to-purple-600"
    when :secondary
      "from-gray-900 via-purple-600 to-pink-600"
    when :success
      "from-gray-900 via-green-600 to-emerald-600"
    end

    render inline: <<~ERB, locals: { badge: badge, title: title, subtitle: subtitle, gradient_text: gradient_text }
      <div class="text-center mb-16 lg:mb-20">
        <% if badge %>
          <span class="inline-block px-4 py-2 bg-gradient-to-r #{COLORS[:primary_gradient_light]} text-indigo-700 #{RADIUS[:full]} text-sm font-semibold mb-4">
            <%= badge %>
          </span>
        <% end %>
        <h2 class="#{TYPOGRAPHY[:h2]} #{COLORS[:text_primary]} mb-6">
          <%= raw title.gsub(/<span>(.*?)<\\/span>/) { |match| "<span class='bg-gradient-to-r #{gradient_text} bg-clip-text text-transparent'>#{$1}</span>" } %>
        </h2>
        <% if subtitle %>
          <p class="max-w-3xl mx-auto #{TYPOGRAPHY[:body_lg]} #{COLORS[:text_secondary]} leading-relaxed">
            <%= subtitle %>
          </p>
        <% end %>
      </div>
    ERB
  end

  # Gradient Background Effect
  def gradient_bg_effect
    <<~HTML.html_safe
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <div class="absolute -top-40 -left-40 w-96 h-96 bg-indigo-400 rounded-full opacity-20 blur-3xl animate-blob"></div>
        <div class="absolute -bottom-40 -right-40 w-96 h-96 bg-purple-400 rounded-full opacity-20 blur-3xl animate-blob animation-delay-2000"></div>
        <div class="absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-pink-400 rounded-full opacity-20 blur-3xl animate-blob animation-delay-4000"></div>
      </div>
    HTML
  end

  # Grid Pattern Overlay
  def grid_pattern_overlay(opacity: 5)
    <<~HTML.html_safe
      <div class="absolute inset-0 opacity-#{opacity} pointer-events-none">
        <div class="w-full h-full" style="background-image: linear-gradient(rgba(99, 102, 241, 0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(99, 102, 241, 0.1) 1px, transparent 1px); background-size: 40px 40px;"></div>
      </div>
    HTML
  end

  # Form Input Styles
  def input_classes(error: false)
    base = "w-full px-4 py-3 #{RADIUS[:lg]} border transition-all duration-200 focus:outline-none focus:ring-2"

    if error
      "#{base} border-red-300 focus:border-red-500 focus:ring-red-500"
    else
      "#{base} border-gray-300 dark:border-gray-600 focus:border-indigo-500 focus:ring-indigo-500 bg-white dark:bg-gray-800"
    end
  end

  # Label Styles
  def label_classes
    "block text-sm font-semibold #{COLORS[:text_primary]} mb-2"
  end
end
