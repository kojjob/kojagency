module PerformanceHelper
  # Optimized image tag with lazy loading and responsive images
  def optimized_image_tag(source, options = {})
    # Set default loading strategy
    options[:loading] ||= 'lazy'
    options[:decoding] ||= 'async'

    # Add importance hint for above-the-fold images
    if options.delete(:eager)
      options[:loading] = 'eager'
      options[:fetchpriority] = 'high'
    end

    # Generate responsive srcset if requested
    if options[:responsive]
      options[:srcset] = generate_srcset(source, options.delete(:sizes_array))
      options[:sizes] ||= generate_sizes_attribute
    end

    # Add dimensions to prevent layout shift
    if options[:width] && options[:height]
      options[:style] ||= ""
      options[:style] += " aspect-ratio: #{options[:width]}/#{options[:height]};"
    end

    image_tag(source, options)
  end

  # Generate srcset for responsive images
  def generate_srcset(source, custom_sizes = nil)
    sizes = custom_sizes || [320, 640, 768, 1024, 1280, 1920]

    # For Active Storage images
    if source.respond_to?(:variant)
      sizes.map do |width|
        variant = source.variant(resize_to_limit: [width, nil])
        "#{url_for(variant)} #{width}w"
      end.join(', ')
    else
      # For regular asset images
      base_path = source.gsub(/\.\w+$/, '')
      extension = source.match(/\.(\w+)$/)[1]

      sizes.map do |width|
        "#{base_path}-#{width}w.#{extension} #{width}w"
      end.join(', ')
    end
  end

  # Generate sizes attribute for responsive images
  def generate_sizes_attribute
    [
      "(max-width: 640px) 100vw",
      "(max-width: 768px) 90vw",
      "(max-width: 1024px) 80vw",
      "(max-width: 1280px) 70vw",
      "1200px"
    ].join(', ')
  end

  # Preload critical resources
  def preload_link_tag(source, options = {})
    options[:rel] = 'preload'
    options[:as] ||= detect_resource_type(source)

    # Add crossorigin for fonts
    if options[:as] == 'font'
      options[:crossorigin] = 'anonymous'
      options[:type] ||= detect_font_type(source)
    end

    link_tag(source, options)
  end

  # Lazy load stylesheets
  def lazy_stylesheet_link_tag(source, options = {})
    # Create a print stylesheet that loads as normal stylesheet onload
    print_options = options.merge(
      media: 'print',
      onload: "this.media='all'; this.onload=null;"
    )

    # Include noscript fallback
    content = stylesheet_link_tag(source, print_options)
    content += content_tag(:noscript) do
      stylesheet_link_tag(source, options)
    end

    content.html_safe
  end

  # Lazy load scripts
  def lazy_javascript_tag(content = nil, options = {}, &block)
    options[:async] = true unless options.key?(:async)
    options[:defer] = true unless options.key?(:defer)

    if content.nil? && block_given?
      content = capture(&block)
    end

    javascript_tag(content, options)
  end

  # Inline critical CSS
  def inline_critical_css
    # Read critical CSS file if it exists
    critical_css_path = Rails.root.join('app', 'assets', 'stylesheets', 'critical.css')

    if File.exist?(critical_css_path)
      content_tag(:style) do
        File.read(critical_css_path).html_safe
      end
    end
  end

  # Generate WebP source for picture element
  def picture_tag(source, options = {})
    content_tag(:picture) do
      output = []

      # Add WebP source
      if source.respond_to?(:variant)
        webp_source = source.variant(format: :webp)
        output << tag(:source, srcset: url_for(webp_source), type: 'image/webp')
      else
        webp_path = source.gsub(/\.\w+$/, '.webp')
        output << tag(:source, srcset: webp_path, type: 'image/webp')
      end

      # Add original format as fallback
      output << optimized_image_tag(source, options)

      safe_join(output)
    end
  end

  private

  def detect_resource_type(source)
    case source
    when /\.css$/i
      'style'
    when /\.js$/i
      'script'
    when /\.(woff2?|ttf|otf|eot)$/i
      'font'
    when /\.(jpg|jpeg|png|gif|svg|webp)$/i
      'image'
    when /\.(mp4|webm|ogg)$/i
      'video'
    else
      'fetch'
    end
  end

  def detect_font_type(source)
    case source
    when /\.woff2$/i
      'font/woff2'
    when /\.woff$/i
      'font/woff'
    when /\.ttf$/i
      'font/ttf'
    when /\.otf$/i
      'font/otf'
    else
      'font/woff2'
    end
  end

  def link_tag(source, options = {})
    tag(:link, { href: source }.merge(options))
  end
end