module ApplicationHelper
  # URL encoding helper for social sharing
  def url_encode(text)
    CGI.escape(text.to_s)
  end

  # Helper for Kaminari pagination
  def paginate(collection)
    return "" unless collection.respond_to?(:current_page)

    content_tag :nav, class: "pagination" do
      safe_join([
        prev_page_link(collection),
        page_numbers(collection),
        next_page_link(collection)
      ])
    end
  end

  private

  def prev_page_link(collection)
    if collection.current_page > 1
      link_to "← Previous", url_for(page: collection.current_page - 1),
              class: "px-4 py-2 bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
    else
      content_tag :span, "← Previous",
                  class: "px-4 py-2 bg-gray-50 text-gray-400 rounded cursor-not-allowed"
    end
  end

  def next_page_link(collection)
    if collection.current_page < collection.total_pages
      link_to "Next →", url_for(page: collection.current_page + 1),
              class: "px-4 py-2 bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
    else
      content_tag :span, "Next →",
                  class: "px-4 py-2 bg-gray-50 text-gray-400 rounded cursor-not-allowed"
    end
  end

  def page_numbers(collection)
    content_tag :div, class: "flex gap-2 mx-4" do
      safe_join((1..collection.total_pages).map do |page|
        if page == collection.current_page
          content_tag :span, page,
                      class: "px-3 py-2 bg-blue-600 text-white rounded"
        else
          link_to page, url_for(page: page),
                  class: "px-3 py-2 bg-gray-100 text-gray-700 rounded hover:bg-gray-200"
        end
      end)
    end
  end
end
